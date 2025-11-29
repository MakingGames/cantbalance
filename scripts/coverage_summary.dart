// ignore_for_file: avoid_print
import 'dart:io';

/// Parses lcov.info and outputs coverage summary (CLI tool)
void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    print('Error: coverage/lcov.info not found');
    print('Run: flutter test --coverage');
    exit(1);
  }

  final content = file.readAsStringSync();
  final lines = content.split('\n');

  var totalLines = 0;
  var coveredLines = 0;
  String? currentFile;
  final fileCoverage = <String, (int total, int covered)>{};

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
    } else if (line.startsWith('LF:')) {
      totalLines += int.parse(line.substring(3));
      if (currentFile != null) {
        fileCoverage[currentFile] = (int.parse(line.substring(3)), 0);
      }
    } else if (line.startsWith('LH:')) {
      coveredLines += int.parse(line.substring(3));
      if (currentFile != null && fileCoverage.containsKey(currentFile)) {
        final (total, _) = fileCoverage[currentFile]!;
        fileCoverage[currentFile] = (total, int.parse(line.substring(3)));
      }
    }
  }

  final percentage = totalLines > 0 ? (coveredLines / totalLines * 100) : 0.0;

  print('');
  print('=' * 60);
  print('CODE COVERAGE SUMMARY');
  print('=' * 60);
  print('');
  print('Total lines:   $totalLines');
  print('Covered lines: $coveredLines');
  print('Coverage:      ${percentage.toStringAsFixed(2)}%');
  print('');
  print('-' * 60);
  print('FILE COVERAGE:');
  print('-' * 60);

  // Sort by file path
  final sortedFiles = fileCoverage.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  for (final entry in sortedFiles) {
    final (total, covered) = entry.value;
    final filePercentage = total > 0 ? (covered / total * 100) : 0.0;
    final status = filePercentage == 100
        ? '✓'
        : filePercentage >= 80
            ? '~'
            : '✗';
    print(
        '$status ${entry.key.padRight(45)} ${filePercentage.toStringAsFixed(0).padLeft(3)}% ($covered/$total)');
  }

  print('');
  print('=' * 60);
  print('Legend: ✓ = 100% | ~ = 80%+ | ✗ = <80%');
  print('=' * 60);
}
