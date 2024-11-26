import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import '../constants.dart';

final _contractProvider = ChangeNotifierProvider((ref) => ContractService());

class ContractService extends ChangeNotifier {
  static AlwaysAliveProviderBase<ContractService> get provider => _contractProvider;
  bool loading = true;

  late final Web3Client _web3client;
  DeployedContract? _UserTasksContract;
  late final EthereumAddress _UserTasksContractAddress;
  late final ContractFunction _increment;
  late final ContractFunction _count;

  String? _UserTasksAbiCode;
  late Credentials? _credentials;

  int count = 0;

  ContractService() {
    _initWeb3();
  }

  Future<void> _initWeb3() async {
    try {
      _web3client = Web3Client(Constants.RPC_URL, Client(), socketConnector: () {
        return IOWebSocketChannel.connect(Constants.WS_URL).cast<String>();
      });
      print("Web3 client initialized");
      await _getAbi();
      await _getCredentials();

      await _getDeployedContracts();
      print(await _web3client.getBlockNumber());
    } catch (e, stackTrace) {
      print("Error initializing Web3: $e\n$stackTrace");
    }
  }

  Future<void> _getAbi() async {
    try {
      String UserTasksAbiFile = await rootBundle.loadString('src/contracts/UserTasks.json');
      final UserTasksAbiJSON = jsonDecode(UserTasksAbiFile);
      print("Loaded ABI from json: $UserTasksAbiJSON");
      if (UserTasksAbiJSON['abi'] == null || UserTasksAbiJSON['networks']['5777']['address'] == null) {
        throw Exception("ABI or contract address not found in UserTasks.json");
      }
      _UserTasksAbiCode = jsonEncode(UserTasksAbiJSON['abi']);
      _UserTasksContractAddress = EthereumAddress.fromHex(UserTasksAbiJSON['networks']['5777']['address']);
      print("ABIs and contract addresses loaded successfully");
    } catch (e) {
      print("Error loading ABI: $e");
      rethrow;
    }
  }
  Future<void> _getCredentials() async {
    try {
      if (Constants.PRIVATE_KEY.isEmpty) {
        throw Exception("Private key is empty. Please provide a valid key.");
      }
      _credentials = EthPrivateKey.fromHex(Constants.PRIVATE_KEY);
      print("Credentials loaded successfully");
    } catch (e) {
      print("Error loading credentials: $e");
      rethrow;
    }
  }
  Future<void> ensureCredentialsInitialized() async {
    if (_credentials == null) {
      await _getCredentials();
      if (_credentials == null) {
        throw Exception("Credentials not initialized.");
      }
    }
  }
  Future<void> _getDeployedContracts() async {
    try {
      if (_UserTasksAbiCode == null) {
        throw Exception("Contract ABI is not initialized.");
      }
      if (_UserTasksContract == null) {
        _UserTasksContract = DeployedContract(
          ContractAbi.fromJson(_UserTasksAbiCode!, "UserTasks"),
          _UserTasksContractAddress,
        );
        _increment = _UserTasksContract!.function("increment");
        _count = _UserTasksContract!.function("count");



        print("Contracts initialized successfully.");
      }
    } catch (e) {
      print("Error initializing contract: $e");
      rethrow;
    }
  }


  Future<void> incrementCount({int countValue = 1}) async {
    loading = true;
    notifyListeners();
    try {
      await ensureCredentialsInitialized();

      if (_UserTasksContract == null) {
        await _getDeployedContracts();
      }

      print("Sending transaction to increment count by $countValue...");
      await _web3client.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _UserTasksContract!,
          function: _increment,
          parameters: [BigInt.from(countValue)],
        ),
        chainId: 1337,
      );
      print("Transaction successful!");
      await getCount();
    } catch (e) {
      print("Error sending transaction: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getCount() async {
    try {
      if (_UserTasksContract == null) {

        await _getDeployedContracts();
      }
      print("Getting count from contract...");
      final num = await _web3client.call(
        contract: _UserTasksContract!,
        function: _count,
        params: [],
      );
      count = int.parse(num.first.toString());
      print("Current count is $count");
    } catch (e) {
      print("Error getting count: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }




  Future<void>  registerUser( String username, String userAddress ) async {
    loading = true;
    notifyListeners();
    try {
      await ensureCredentialsInitialized();

      await _getDeployedContracts();

      final address = EthereumAddress.fromHex(userAddress);
      print("Sending transaction to address $address...");
      _UserTasksContract = DeployedContract(
        ContractAbi.fromJson(_UserTasksAbiCode!, "UserTasks"),
        _UserTasksContractAddress,
      );
      await _web3client.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _UserTasksContract!,
          function: _UserTasksContract!.function("registerUser"),
          parameters: [username,address],
        ),
        chainId: 1337,
      );

      print("Transaction successful!");
      await getCount();
    } catch (e) {
      print("Error sending transactions: $e");
      throw Exception("User is already registered.");

    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTasks(EthereumAddress userAddress) async {
    try {
      await ensureCredentialsInitialized();
      await _getDeployedContracts();

      print("Fetching tasks from blockchain...");

      final taskData = await _web3client.call(
        contract: _UserTasksContract!,
        function: _UserTasksContract!.function("fetchUserTasks"),
        params: [userAddress],
      );

      print(taskData);
      List<dynamic> decodedTasks = taskData[0];
      List<Map<String, dynamic>> userTasks = [];

      for (var task in decodedTasks) {
        int id = (task[0] as BigInt).toInt();
        String name = task[1] as String;
        String hour = task[2] as String;
        bool status = task[3] as bool;
        String day = task[4] as String;

        print('ID: $id Task: $name, Hour: $hour, Status: $status, Day: $day');

        userTasks.add({
          "id": id,
          "name": name,
          "hour": hour,
          "status": status,
          "day": day,
        });
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/user_tasks.json';
      final file = File(filePath);

      await file.writeAsString(json.encode(userTasks));


      print("Tasks saved to file: $filePath");
    } catch (e) {
      print("Error fetching tasks: $e");
    }
  }


  Future<void> addTask(String name, String hour, String day) async {
    try {
      await ensureCredentialsInitialized();
      await _getDeployedContracts();

      await _web3client.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _UserTasksContract!,
          function: _UserTasksContract!.function('addTask'),
          parameters: [name, hour,day ],
        ),
        chainId: 1337,
      );

      print("Task added successfully!");
    } catch (e) {
      print("Error adding task: $e");
    }
  }


  Future<void>deleteTask(int taskId) async {
    try {
      await ensureCredentialsInitialized();
      await _getDeployedContracts();

      await _web3client.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _UserTasksContract!,
          function: _UserTasksContract!.function('deleteTask'),
          parameters: [BigInt.from(taskId)],
        ),
        chainId: 1337,
      );

      print("Task delete successfully!");
    } catch (e) {
      print("Error delete task: $e");
      if (e is RPCError) {
        print('Error deleting task: ${e.message}');}
    }
  }


  Future<void>updateTaskStatus(int taskId, bool status) async {
    try {
      await ensureCredentialsInitialized();
      await _getDeployedContracts();

      await _web3client.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _UserTasksContract!,
          function: _UserTasksContract!.function('updateTaskStatus'),
          parameters: [BigInt.from(taskId), status],
        ),
        chainId: 1337,
      );

      print("Task updated successfully!");
    } catch (e) {
      print("Error updated task: $e");
    }
  }


  Future<void> editTask(int taskId, String newName, String newHour, String newDay) async {
    try {
      await ensureCredentialsInitialized();
      await _getDeployedContracts();

      await _web3client.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _UserTasksContract!,
          function: _UserTasksContract!.function('editTask'),
          parameters: [
            BigInt.from(taskId),
            newName,
            newHour,
            newDay,
          ],
        ),
        chainId: 1337,
      );

      print("Task edited successfully!");
    } catch (e) {
      print("Error editing task: $e");
    }
  }

  Future<void> assignTask(int taskId, String recipientAddress) async {
    try {
      await ensureCredentialsInitialized();
      await _getDeployedContracts();

      final recipient = EthereumAddress.fromHex(recipientAddress);
      await _web3client.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _UserTasksContract!,
          function: _UserTasksContract!.function('assignTask'),
          parameters: [
            BigInt.from(taskId),
            recipient,
          ],
        ),
        chainId: 1337,
      );

      print("Task assigned successfully!");
    } catch (e) {
      print("Error assigning task: $e");
      throw Exception("User is not already registered.");
    }
  }



}





