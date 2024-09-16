import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../components/bottom_appbar.dart';
import '../components/my_tasklist.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  void add_task(){
     print(("111111111111111111"));
  }
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
                style: const TextStyle(
                  color: Color.fromRGBO(22, 71, 147, 1.0),
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
                    color: Color.fromRGBO(30, 76, 168, 1.0),
                  ),
                  weekdayStyle: TextStyle(
                    color: Color.fromRGBO(30, 76, 168, 1.0),
                  ),
                ),
                calendarStyle: const CalendarStyle(
                  todayTextStyle: TextStyle(
                    color: Color.fromRGBO(30, 76, 168, 1.0),
                    fontWeight: FontWeight.bold,
                  ),
                  todayDecoration:BoxDecoration(
                    color: Color.fromRGBO(136, 13, 13, 0),
                    shape: BoxShape.circle,
                  ) ,
                  selectedTextStyle :TextStyle(
                    color: Color.fromRGBO(30, 76, 168, 1.0),

                  ),
                  selectedDecoration:BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 1.0),
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle:TextStyle(
                    color: Color.fromRGBO(30, 76, 168, 1.0),

                  ),
                  weekendTextStyle: TextStyle(
                    color: Color.fromRGBO(30, 76, 168, 1.0),

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
                    (context, index) => TaskListCard(theme: theme),
                childCount:5,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape:  RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        elevation: 14.0,
        onPressed: add_task,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,

      bottomNavigationBar: MyBottomAppBar(),
    );
  }
}


