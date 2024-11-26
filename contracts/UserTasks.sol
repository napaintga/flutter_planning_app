// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserTasks {
    struct Task {
        uint256 id;
        string name;
        string hour;
        bool status;
        string day;
        address owner;
    }
    struct User {
        string userName;
        address userAddress;
        uint256[] taskIds;
    }
    uint256 private _count;
    function increment(uint256 countValue) public {
        _count += countValue;
    }

    function count() public view returns (uint256) {
        return _count;
    }
    uint256 private _taskIdCounter;
    Task[] public tasks;
    mapping(address => User) public users;
    mapping(address => bool) public isUserRegistered;

    event UserRegistered(string userName, address userAddress);
    event TaskAdded(uint256 taskId, string name, address owner);
    event TaskUpdatedStatus(uint256 taskId, bool status, address owner);
    event TaskDeleted(uint256 taskId, address owner);
    event TaskUpdated(uint256 taskId, string name, string hour, string day, bool status, address owner);

    function registerUser(string memory userName, address userAddress) public {
        require(!isUserRegistered[userAddress], "User already registered.");

        isUserRegistered[userAddress] = true;

        emit UserRegistered(userName, userAddress);
    }


    function addTask(
        string memory name,
        string memory hour,
        string memory day
    ) public {
        require(isUserRegistered[msg.sender], "User not registered.");

        uint256 newTaskId = _taskIdCounter++; // Генеруємо новий ID
        tasks.push(Task(newTaskId, name, hour, false, day, msg.sender));
        users[msg.sender].taskIds.push(newTaskId);

        emit TaskAdded(newTaskId, name, msg.sender);
    }

    function editTask(
        uint256 taskId,
        string memory newName,
        string memory newHour,
        string memory newDay
    ) public {
        Task storage task = _getTaskById(taskId);
        require(task.owner == msg.sender, "Not authorized to edit this task.");

        task.name = newName;
        task.hour = newHour;
        task.day = newDay;

        emit TaskUpdated(taskId, newName, newHour, newDay, task.status, msg.sender);
    }

    function getUserTasks(address userAddress) public view returns (uint256[] memory) {
        require(isUserRegistered[userAddress], "User not registered.");
        return users[userAddress].taskIds;
    }



    function updateTaskStatus(uint256 taskId, bool status) public {
        Task storage task = _getTaskById(taskId);
        task.status = status;

        emit TaskUpdatedStatus(taskId, status, msg.sender);
    }

    function deleteTask(uint256 taskId) public {
        Task storage task = _getTaskById(taskId);

        uint256[] storage userTasks = users[msg.sender].taskIds;
        for (uint256 i = 0; i < userTasks.length; i++) {
            if (userTasks[i] == taskId) {
                userTasks[i] = userTasks[userTasks.length - 1];
                userTasks.pop();
                break;
            }
        }

        delete tasks[taskId];

        emit TaskDeleted(taskId, msg.sender);
    }

    function getTask(uint256 taskId) public view returns (Task memory) {
        return _getTaskById(taskId);
    }

    function _getTaskById(uint256 taskId) private view returns (Task storage) {
        for (uint256 i = 0; i < tasks.length; i++) {
            if (tasks[i].id == taskId) {
                return tasks[i];
            }
        }
        revert("Task not found.");
    }

    function fetchUserTasks(address userAddress) public view returns (Task[] memory) {
        require(isUserRegistered[userAddress], "User not registered.");

        uint256[] memory taskIds = users[userAddress].taskIds;
        Task[] memory userTasks = new Task[](taskIds.length);

        for (uint256 i = 0; i < taskIds.length; i++) {
            userTasks[i] = _getTaskById(taskIds[i]);
        }

        return userTasks;
    }

    function assignTask(uint256 taskId, address newOwner) public {
        require(taskId < tasks.length, "Invalid task ID.");
        require(isUserRegistered[newOwner], "New owner is not registered.");

        Task storage task = tasks[taskId];
        require(task.owner == msg.sender, "You do not own this task.");

        address oldOwner = task.owner;
        task.owner = newOwner;

        uint256[] storage oldOwnerTasks = users[oldOwner].taskIds;
        for (uint256 i = 0; i < oldOwnerTasks.length; i++) {
            if (oldOwnerTasks[i] == taskId) {
                oldOwnerTasks[i] = oldOwnerTasks[oldOwnerTasks.length - 1];
                oldOwnerTasks.pop();
                break;
            }
        }

        users[newOwner].taskIds.push(taskId);

        emit TaskUpdatedStatus(taskId, task.status, newOwner);
    }

}