import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:untitled/auth/register_or_login.dart';
import 'package:untitled/pages/login_page.dart';
import 'package:untitled/pages/register_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ',
      color: Colors.white70,
      theme: ThemeData(

        scaffoldBackgroundColor: Colors.grey.shade900,
        colorScheme: ColorScheme.fromSeed(
          primary: const Color.fromRGBO(73, 102, 151, 1.0),
          seedColor: Colors.black,
          secondary: Colors.white70,
        ),
        useMaterial3: true,
        fontFamily: 'Raleway',
      ),
      home:   _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatefulWidget {

  @override
   _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<_HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayName = DateFormat('MMMM, yyyy').format(_selectedDay); // Format: day name and year

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            title: Container(
              padding: const EdgeInsets.only(top: 12),
              alignment: Alignment.center,
              child: Text(
                dayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.secondaryHeaderColor,
                  fontSize: 25,
                ),
              ),
            ),
            backgroundColor: theme.primaryColor,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: TableCalendar(
                daysOfWeekStyle:const DaysOfWeekStyle(
                  weekendStyle: TextStyle(
                    color: Color.fromRGBO(46, 46, 46, 1.0) ,
                  ),
                  weekdayStyle: TextStyle(
                    color: Color.fromRGBO(46, 46, 46, 1.0) ,
                  ),
                ),
                calendarStyle: const CalendarStyle(
                  todayTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,

                  ),
                    todayDecoration:BoxDecoration(
                      color: Color.fromRGBO(136, 13, 13, 0),
                      shape: BoxShape.circle,
                    ) ,
                    selectedTextStyle :TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1.0),

                    ),
                    selectedDecoration:BoxDecoration(
                      color: Color.fromRGBO(87, 85, 85, 1.0),
                        shape: BoxShape.circle,
                    ),
                    defaultTextStyle:TextStyle(
                      color: Colors.black,

                ),
                  weekendTextStyle: TextStyle(
                    color: Colors.black,

                  ),

                ),

                headerVisible: false,
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.week,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    _selectedDay = focusedDay;
                  });
                },
                availableGestures: AvailableGestures.horizontalSwipe, // Swipe gesture enabled
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10,),),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => Container(
                width: double.infinity,
                height: 50,

                margin: const EdgeInsets.only(bottom: 13),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      border: Border.all(
                        color: Colors.grey,
                        width: 5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),

              ),
              childCount: 20, // Set this to your desired number of list items
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
