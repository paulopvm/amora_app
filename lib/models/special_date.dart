import 'package:flutter/material.dart';

/// Modelo para datas especiais no calendário
class SpecialDate {
  final DateTime date;
  final String title;
  final String description;
  final SpecialDateType type;
  final Color? color;

  SpecialDate({
    required this.date,
    required this.title,
    required this.description,
    required this.type,
    this.color,
  });
}

/// Tipos de datas especiais
enum SpecialDateType {
  anniversary,     // Aniversário de namoro
  monthiversary,   // Mesversário
  custom,          // Data personalizada
}

/// Serviço para gerenciar datas especiais
class SpecialDatesService {
  final DateTime relationshipStartDate;
  
  SpecialDatesService({required this.relationshipStartDate});
  
  /// Gera datas especiais com base na data de início do relacionamento
  List<SpecialDate> generateSpecialDates(DateTime startDate, DateTime endDate) {
    List<SpecialDate> specialDates = [];
    
    // Adiciona aniversários de namoro
    DateTime currentDate = DateTime(relationshipStartDate.year, relationshipStartDate.month, relationshipStartDate.day);
    while (currentDate.isBefore(endDate)) {
      if (currentDate.isAfter(startDate) || currentDate.isAtSameMomentAs(startDate)) {
        int yearsSince = currentDate.year - relationshipStartDate.year;
        if (yearsSince > 0) {
          specialDates.add(
            SpecialDate(
              date: currentDate,
              title: '$yearsSince ${yearsSince == 1 ? 'ano' : 'anos'} juntos',
              description: 'Aniversário de namoro',
              type: SpecialDateType.anniversary,
              color: Colors.red,
            ),
          );
        }
      }
      // Avança para o próximo ano
      currentDate = DateTime(currentDate.year + 1, currentDate.month, currentDate.day);
    }
    
    // Adiciona mesversários
    currentDate = DateTime(relationshipStartDate.year, relationshipStartDate.month, relationshipStartDate.day);
    while (currentDate.isBefore(endDate)) {
      if (currentDate.isAfter(startDate) || currentDate.isAtSameMomentAs(startDate)) {
        int monthsSince = (currentDate.year - relationshipStartDate.year) * 12 + 
                          currentDate.month - relationshipStartDate.month;
        
        if (monthsSince > 0 && monthsSince % 12 != 0) { // Não duplicar com aniversários anuais
          specialDates.add(
            SpecialDate(
              date: currentDate,
              title: '$monthsSince ${monthsSince == 1 ? 'mês' : 'meses'} juntos',
              description: 'Mesversário',
              type: SpecialDateType.monthiversary,
              color: Colors.pink,
            ),
          );
        }
      }
      
      // Avança para o próximo mês
      int nextMonth = currentDate.month + 1;
      int nextYear = currentDate.year;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }
      
      // Ajusta o dia caso o próximo mês não tenha o mesmo número de dias
      int day = currentDate.day;
      if (day > 28) {
        // Verifica o último dia do próximo mês
        int lastDayOfNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        day = day > lastDayOfNextMonth ? lastDayOfNextMonth : day;
      }
      
      currentDate = DateTime(nextYear, nextMonth, day);
    }
    
    return specialDates;
  }
  
  /// Retorna datas especiais para um mês específico
  List<SpecialDate> getSpecialDatesForMonth(DateTime month) {
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);
    
    return generateSpecialDates(startDate, endDate);
  }
  
  /// Adiciona uma data personalizada à lista
  List<SpecialDate> addCustomDate(
    List<SpecialDate> dates, 
    DateTime date, 
    String title, 
    String description, 
    {Color? color}
  ) {
    dates.add(
      SpecialDate(
        date: date,
        title: title,
        description: description,
        type: SpecialDateType.custom,
        color: color ?? Colors.blue,
      ),
    );
    return dates;
  }
}
