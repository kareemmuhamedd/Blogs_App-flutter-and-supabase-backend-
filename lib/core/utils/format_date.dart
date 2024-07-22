import 'package:intl/intl.dart';

String formateDateBydMMMYYYY(DateTime dateTime) {
  return DateFormat('d MMM, yyyy').format(dateTime);
}
