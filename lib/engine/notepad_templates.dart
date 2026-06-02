// lib/engine/notepad_templates.dart
//
// Notepad V2 Tier C: predefined document templates.
//
// Each template creates a fresh NotepadDocument pre-populated with
// a useful skeleton. Accessible from the new-doc menu.

import 'notepad.dart';

class NotepadTemplate {
  final String id;
  final String name;
  final String description;
  final List<String> lines;

  const NotepadTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.lines,
  });

  NotepadDocument createDocument() {
    final doc = NotepadDocument.fresh(name: name);
    doc.lines.clear();
    for (final source in lines) {
      doc.lines.add(NotepadLine.fresh(source: source));
    }
    return doc;
  }
}

class NotepadTemplates {
  static const List<NotepadTemplate> all = [
    NotepadTemplate(
      id: 'budget',
      name: 'Budget Calculator',
      description: 'Income and expense tracker with running total.',
      lines: [
        '## Income',
        'salary = 4500',
        'freelance = 800',
        'subtotal',
        '',
        '## Expenses',
        'rent = 1200',
        'utilities = 150',
        'groceries = 400',
        'transport = 100',
        'subtotal',
        '',
        '## Balance',
        'salary + freelance - rent - utilities - groceries - transport',
        'total',
      ],
    ),
    NotepadTemplate(
      id: 'homework',
      name: 'Homework Helper',
      description: 'Structured problem-solving with headings.',
      lines: [
        '## Problem 1',
        '// Write the equation here',
        '',
        '',
        '## Problem 2',
        '// Write the equation here',
        '',
        '',
        '## Problem 3',
        '// Write the equation here',
        '',
        '',
        '---',
        '// Score: count correct answers above',
      ],
    ),
    NotepadTemplate(
      id: 'unit_conversion',
      name: 'Unit Conversion Sheet',
      description: 'Common conversions with inline unit arithmetic.',
      lines: [
        '## Length',
        '1 mile in km',
        '1 ft in m',
        '1 inch in cm',
        '',
        '## Weight',
        '1 lb in kg',
        '1 oz in g',
        '',
        '## Temperature',
        '// Use the unit converter for temperature (offset units)',
        '',
        '## Speed',
        '60 mph in km/h',
        '100 km/h in mph',
      ],
    ),
    NotepadTemplate(
      id: 'statistics',
      name: 'Data Analysis',
      description: 'Enter data and compute descriptive statistics.',
      lines: [
        '## Data',
        '// Enter your values as assignments',
        'x1 = 12',
        'x2 = 15',
        'x3 = 18',
        'x4 = 22',
        'x5 = 25',
        '',
        '## Summary',
        '(x1 + x2 + x3 + x4 + x5) / 5',
        'count',
        'average',
      ],
    ),
    NotepadTemplate(
      id: 'physics',
      name: 'Physics Lab Report',
      description: 'Measurements, calculations, and results.',
      lines: [
        '## Constants',
        'g = 9.81',
        'pi',
        '',
        '## Measurements',
        '// Enter measured values',
        'm = 0.5',
        'v = 3.2',
        'h = 1.5',
        '',
        '## Calculations',
        '// Kinetic energy',
        '0.5 * m * v^2',
        '// Potential energy',
        'm * g * h',
        '// Total energy',
        'Ans + 0.5 * m * v^2',
        '',
        '---',
        'total',
      ],
    ),
  ];
}
