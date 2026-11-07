import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarApp extends StatefulWidget {
  @override
  State<CalendarApp> createState() => CalendarAppState();
}

class CalendarAppState extends State<CalendarApp> {
  Locale _locale = const Locale('ru');

  void _toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'ru' ? const Locale('en') : const Locale('ru');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: CalendaPage(onToggleLanguage: _toggleLanguage),
    );
  }
}

class CalendaPage extends StatefulWidget {
  final VoidCallback onToggleLanguage;
  const CalendaPage({
    super.key,
    required this.onToggleLanguage,
  });

  @override
  State<CalendaPage> createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendaPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  final Map<DateTime, List<String>> _events = {};

  List<String> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _events[key] ?? [];
  }

  void _addEvents() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Новое событие'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Название события',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final key = DateTime(
                  _selectedDay.year,
                  _selectedDay.month,
                  _selectedDay.day,
                );
                
                setState(() {
                  _events.putIfAbsent(key, () => []);
                  _events[key]!.add(controller.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventsForDay(_selectedDay);
    // Получаем текущий язык для правильного перевода дней недели в TableCalendar
    final currentLanguageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: widget.onToggleLanguage,
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvents,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: currentLanguageCode, // Передаем язык в сам календарь
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020), 
            lastDay: DateTime.utc(2030), // Поставили запятую
            selectedDayPredicate: (day) {
              return isSameDay(day, _selectedDay);
            }, // Поставили запятую
            // Изменили на обычное нажатие, чтобы календарь реагировал сразу, а не по долгому зажатию
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // Исправили ошибку дублирования _selectedDay
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ), // Поставили запятую
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ), // Закрыли скобку TableCalendar и поставили запятую
          
          const SizedBox(height: 20),

          // ПОЛНОСТЬЮ ИСПРАВЛЕННЫЙ И ДОПИСАННЫЙ ВЫВОД ТЕКСТА:
          Text(
            currentLanguageCode == 'ru' 
                ? 'Выбрано: ${_selectedDay.day}.${_selectedDay.month}.${_selectedDay.year}'
                : 'Selected: ${_selectedDay.month}/${_selectedDay.day}/${_selectedDay.year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 12),

          // ДОБАВЛЕНО: Вывод списка добавленных событий на экран
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Text(
                      currentLanguageCode == 'ru' ? 'Нет событий на этот день' : 'No events for this day',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.event, color: Colors.teal),
                          title: Text(events[index]),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
