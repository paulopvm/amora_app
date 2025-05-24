import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/special_date.dart';

/// Widget de calendário para o casal
/// 
/// Exibe um calendário mensal com marcação de datas especiais
class CoupleCalendar extends StatefulWidget {
  final DateTime relationshipStartDate;
  final Function(DateTime, List<SpecialDate>)? onDaySelected;
  final Function(DateTime)? onAddEvent;
  final Function()? onGoogleCalendarSync;

  const CoupleCalendar({
    super.key,
    required this.relationshipStartDate,
    this.onDaySelected,
    this.onAddEvent,
    this.onGoogleCalendarSync,
  });

  @override
  State<CoupleCalendar> createState() => _CoupleCalendarState();
}

class _CoupleCalendarState extends State<CoupleCalendar> {
  late final ValueNotifier<List<SpecialDate>> _selectedEvents;
  late final SpecialDatesService _datesService;
  late List<SpecialDate> _monthEvents;
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  
  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _datesService = SpecialDatesService(relationshipStartDate: widget.relationshipStartDate);
    _monthEvents = _datesService.getSpecialDatesForMonth(_focusedDay);
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
    
    // Adicionar alguns eventos personalizados mockados
    _monthEvents = _datesService.addCustomDate(
      _monthEvents,
      DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day + 5),
      'Jantar romântico',
      'Restaurante favorito às 20h',
      color: Colors.deepPurple,
    );
    
    _monthEvents = _datesService.addCustomDate(
      _monthEvents,
      DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day + 10),
      'Cinema',
      'Ver o novo filme de romance',
      color: Colors.teal,
    );
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<SpecialDate> _getEventsForDay(DateTime day) {
    return _monthEvents.where((event) => 
      event.date.year == day.year && 
      event.date.month == day.month && 
      event.date.day == day.day
    ).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      final events = _getEventsForDay(selectedDay);
      _selectedEvents.value = events;
      
      if (widget.onDaySelected != null) {
        widget.onDaySelected!(selectedDay, events);
      }
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      _monthEvents = _datesService.getSpecialDatesForMonth(focusedDay);
      
      // Adicionar eventos mockados para o mês
      final day = 15;
      _monthEvents = _datesService.addCustomDate(
        _monthEvents, 
        DateTime(focusedDay.year, focusedDay.month, day),
        'Evento mensal mockado',
        'Descrição para evento mockado',
        color: Colors.orange,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Título do calendário
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(Icons.calendar_month),
              const SizedBox(width: 8),
              Text(
                'Calendário do Casal',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              // Botão para adicionar ao Google Calendar
              IconButton(
                icon: const Icon(Icons.sync),
                tooltip: 'Sincronizar com Google Calendar',
                onPressed: widget.onGoogleCalendarSync,
              ),
            ],
          ),
        ),
        
        // Calendário
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar<SpecialDate>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              locale: 'pt_BR',
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                markersMaxCount: 3,
                markerDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: _onDaySelected,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onPageChanged: _onPageChanged,
              eventLoader: _getEventsForDay,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return null;
                  
                  // Verificar se há aniversário ou mesversário para mostrar o coração
                  final hasSpecialDate = events.any(
                    (e) => e.type == SpecialDateType.anniversary || e.type == SpecialDateType.monthiversary
                  );
                  
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasSpecialDate ? Colors.transparent : Colors.transparent,
                      ),
                      width: 16,
                      height: 16,
                      child: Center(
                        child: hasSpecialDate
                          ? const Icon(Icons.favorite, size: 14, color: Colors.red)
                          : Container(
                              height: 6,
                              width: 6,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        // Lista de eventos do dia selecionado
        ValueListenableBuilder<List<SpecialDate>>(
          valueListenable: _selectedEvents,
          builder: (context, value, _) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Eventos em ${DateFormat('dd/MM/yyyy').format(_selectedDay)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // Botão para adicionar evento
                        IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: 'Adicionar evento',
                          onPressed: widget.onAddEvent != null 
                              ? () => widget.onAddEvent!(_selectedDay)
                              : null,
                        ),
                      ],
                    ),
                    const Divider(),
                    value.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Center(
                              child: Text('Nenhum evento nesta data'),
                            ),
                          )
                        : Column(
                            children: value.map((event) {
                              // Ícone baseado no tipo de evento
                              IconData eventIcon;
                              switch (event.type) {
                                case SpecialDateType.anniversary:
                                  eventIcon = Icons.cake;
                                  break;
                                case SpecialDateType.monthiversary:
                                  eventIcon = Icons.favorite;
                                  break;
                                case SpecialDateType.custom:
                                  eventIcon = Icons.event_note;
                              }
                            
                              return ListTile(
                                leading: Icon(
                                  eventIcon,
                                  color: event.color ?? Theme.of(context).colorScheme.primary,
                                ),
                                title: Text(
                                  event.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(event.description),
                                trailing: event.type == SpecialDateType.custom
                                    ? IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          // Editar evento (mockado)
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Edição de evento será implementada'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                      )
                                    : null,
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
