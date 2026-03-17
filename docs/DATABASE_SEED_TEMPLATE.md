# Database Seed Template

Use this template to manually enter your 100 MVP questions.

---

## CASELETS (10 total)

### Caselet 1: LR - Seating Arrangement
```sql
INSERT INTO caselets (section, subsection, topic, caselet_text, has_visual, visual_path, visual_type, difficulty, source_book, source_page) VALUES (
  'DILR',
  'LR',
  'Seating Arrangement',
  'Ten cricket players - Rohit (P), Dhawan (Q), Kohli (R), Rahane (S), Yuvraj (T), Raina (U), Dhoni (V), Ashwin (W), Jadeja (X), and Shami (Y) - are sitting in a row of 10 seats numbered 1 to 10 from left to right.
  
  Given:
  a) There are 5 players between Rahane and Yuvraj
  b) Dhoni does not sit at either end
  c) Rohit, Dhawan, and Raina sit together in that order
  d) Shami sits 7 seats away from Rohit
  e) Kohli sits immediately to the right of Shami',
  1,
  'assets/images/caselets/c_1.png',
  'seating_diagram',
  'Medium',
  'Arun Sharma LR 12th Ed',
  101
);
-- Last inserted caselet_id = 1

INSERT INTO questions (section, subsection, topic, caselet_id, question_number, question_text, question_type, option_a, option_b, option_c, option_d, correct_answer, explanation, source_book, source_page) VALUES
(
  'DILR',
  'LR',
  'Seating Arrangement',
  1,
  1,
  'If Yuvraj sits immediately to the right of Raina, then which seat does Rahane occupy?',
  'MCQ',
  '8',
  '9',
  '10',
  'Cannot be determined',
  'c',
  'If Yuvraj sits immediate right to Raina (position 4), then according to condition (a), Rahane must be at seat 10. From the arrangement analysis, this is the only valid configuration.',
  'Arun Sharma LR 12th Ed',
  101
),
(
  'DILR',
  'LR',
  'Seating Arrangement',
  1,
  2,
  'If there are only two players sitting between Kohli and Rahane, who sits immediately to the right of Rahane?',
  'MCQ',
  'Dhoni',
  'Jadeja',
  'Ashwin',
  'None of these',
  'a',
  'From Case B analysis, when 2 players sit between Kohli and Rahane, Dhoni sits immediately right of Rahane.',
  'Arun Sharma LR 12th Ed',
  101
),
(
  'DILR',
  'LR',
  'Seating Arrangement',
  1,
  3,
  'How many players are sitting between Ashwin and Jadeja?',
  'MCQ',
  '0',
  '1',
  '2',
  '3',
  'a',
  'In both valid cases, Ashwin and Jadeja sit adjacent to each other. Therefore, 0 players between them.',
  'Arun Sharma LR 12th Ed',
  101
);
```

---

### Caselet 2: DI - Bar Chart
```sql
-- [Screenshot the bar chart from Arun Sharma DI.pdf page 50-100]
-- Save as: assets/images/caselets/c_2.png

INSERT INTO caselets (section, subsection, topic, caselet_text, has_visual, visual_path, visual_type, difficulty, source_book, source_page) VALUES (
  'DILR',
  'DI',
  'Bar Charts',
  'The bar chart shows the sales (in lakhs) of five products A, B, C, D, E across three years 2018, 2019, 2020.',
  1,
  'assets/images/caselets/c_2.png',
  'bar_chart',
  'Easy',
  'Arun Sharma DI 12th Ed',
  75
);
-- Last inserted caselet_id = 2

-- [Add 3-4 questions based on this chart]
INSERT INTO questions (section, subsection, topic, caselet_id, question_number, question_text, question_type, option_a, option_b, option_c, option_d, correct_answer, explanation, source_book, source_page) VALUES
(
  'DILR',
  'DI',
  'Bar Charts',
  2,
  1,
  'Which product showed the highest growth from 2018 to 2020?',
  'MCQ',
  'Product A',
  'Product B',
  'Product C',
  'Product D',
  'b',
  '[Add explanation based on chart data]',
  'Arun Sharma DI 12th Ed',
  75
);
-- [Continue for questions 2, 3...]
```

---

## STANDALONE QA QUESTIONS (40 total)

### QA - Number Systems (10 questions)

```sql
INSERT INTO questions (section, subsection, topic, question_text, question_type, has_diagram, diagram_path, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty, source_book, source_page) VALUES
(
  'QA',
  NULL,
  'Number Systems',
  'M is a two-digit number which has the property that the product of factorials of its digits is greater than the sum of factorials of its digits. How many values of M exist?',
  'MCQ',
  0,
  NULL,
  '56',
  '64',
  '63',
  'None of these',
  'c',
  'For a two-digit number M = 10a + b (where a ∈ {1-9}, b ∈ {0-9}), we need: a! × b! > a! + b!
  
  Testing systematically:
  - If a=1: 1! × b! > 1! + b! → b! > 1 + b! → Never true
  - If a=2: 2! × b! > 2! + b! → 2b! > 2 + b! → True for b ≥ 3
    Valid: 23, 24, 25, 26, 27, 28, 29 (7 values)
  - If a≥3: 3! × b! > 3! + b! → 6b! > 6 + b! → True for b ≥ 2
    For a=3: 32-39 (8 values)
    For a=4: 42-49 (8 values)
    ...continuing this pattern for a=5,6,7,8,9
  
  Total = 7 + 8×7 = 63',
  'Hard',
  'Arun Sharma QA 12th Ed',
  101
);

INSERT INTO questions (section, subsection, topic, question_text, question_type, has_diagram, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty, source_book, source_page) VALUES
(
  'QA',
  NULL,
  'Number Systems',
  'Find the 28383rd term of the series: 123456789101112...',
  'MCQ',
  0,
  '3',
  '4',
  '9',
  '7',
  'a',
  'The series concatenates natural numbers: 1, 2, 3, ..., 9, 10, 11, 12, ...
  
  Counting digits:
  - 1-digit numbers (1-9): 9 numbers × 1 digit = 9 digits
  - 2-digit numbers (10-99): 90 numbers × 2 digits = 180 digits
  - 3-digit numbers (100-999): 900 numbers × 3 digits = 2700 digits
  - 4-digit numbers (1000-9999): 9000 numbers × 4 digits = 36000 digits
  
  Cumulative: 9 + 180 + 2700 = 2889 digits up to 999
  
  28383 - 2889 = 25494 digits into 4-digit numbers
  25494 ÷ 4 = 6373 remainder 2
  
  So we need the 2nd digit of the 6374th four-digit number.
  6374th four-digit number = 1000 + 6373 = 7373
  2nd digit of 7373 = 3',
  'Hard',
  'Arun Sharma QA 12th Ed',
  101
);

-- [Continue for remaining 8 Number Systems questions...]
```

### QA - Geometry (10 questions, 8 with diagrams)

```sql
-- [Screenshot triangle diagram from QA.pdf]
-- Save as: assets/images/questions/q_15.png

INSERT INTO questions (section, subsection, topic, question_text, question_type, has_diagram, diagram_path, option_a, option_b, option_c, option_d, correct_answer, explanation, explanation_image, difficulty, source_book, source_page) VALUES
(
  'QA',
  NULL,
  'Geometry - Triangles',
  'In triangle ABC, angle A = 60°, AB = 10 cm, and AC = 8 cm. Find the length of BC.',
  'MCQ',
  1,
  'assets/images/questions/q_15.png',
  '2√19 cm',
  '2√21 cm',
  '2√23 cm',
  '2√17 cm',
  'a',
  'Using cosine rule: BC² = AB² + AC² - 2(AB)(AC)cos(A)
  
  BC² = 10² + 8² - 2(10)(8)cos(60°)
  BC² = 100 + 64 - 160(0.5)
  BC² = 164 - 80
  BC² = 84
  BC² = 4 × 21
  BC = 2√21 cm',
  'assets/images/explanations/exp_15.png',
  'Medium',
  'Arun Sharma QA 12th Ed',
  234
);

-- [Continue for remaining 9 Geometry questions...]
```

---

## VARC QUESTIONS (30 total)

### VARC - RC Passage 1

```sql
INSERT INTO questions (section, subsection, topic, question_text, question_type, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty, source_book, source_page) VALUES
(
  'VARC',
  'RC',
  'Science & Technology',
  'PASSAGE: [Full passage text from VARC.pdf page 200-202 about aviation history]
  
  According to the first paragraph of the passage, which of the following statements is NOT false?',
  'MCQ',
  'Frank Whittle and Hans von Ohain were the first to conceive of jet propulsion.',
  'Supersonic fighter planes were first used in the Second World War.',
  'No man had traveled faster than sound until the 1950s.',
  'The exploitation of jet propulsion for supersonic aviation has been remarkably fast.',
  'd',
  'Option (d) is correct as the passage states that jet propulsion evolved from conception to supersonic flight in just 24 years (1930s to 1950s), which is remarkably fast technological progress.',
  'Medium',
  'Arun Sharma VARC 12th Ed',
  201
);

-- [Continue for 4 more questions from same passage]
-- [Then add Passage 2 with 5 questions]
```

### VARC - VA (20 questions)

```sql
INSERT INTO questions (section, subsection, topic, question_text, question_type, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty, source_book, source_page) VALUES
(
  'VARC',
  'VA',
  'Parajumbles',
  'Arrange the following sentences in the correct order:
  
  A. The company announced record profits despite the economic downturn.
  B. Investors were surprised by the strong performance.
  C. However, analysts had predicted modest growth.
  D. The CEO attributed success to cost-cutting measures.',
  'MCQ',
  'ABDC',
  'ACBD',
  'ABCD',
  'CABD',
  'b',
  'Correct order: A-C-B-D
  
  A introduces the topic (record profits).
  C provides context (analysts predicted modest growth).
  B shows reaction (investors surprised - because growth exceeded predictions).
  D explains reason (CEO attributes to cost-cutting).',
  'Easy',
  'Arun Sharma VARC 12th Ed',
  145
);

-- [Continue for remaining 19 VA questions]
```

---

## QUICK SEED SCRIPT

Once you have all questions in SQL format above, create this file:

**File: `seed_database.dart`**

```dart
import 'package:sqflite/sqflite.dart';

Future<void> seedDatabase(Database db) async {
  // Insert caselets
  await db.execute('''
    INSERT INTO caselets (...) VALUES (...);
    -- [Paste all caselet INSERT statements]
  ''');
  
  // Insert questions
  await db.execute('''
    INSERT INTO questions (...) VALUES (...);
    -- [Paste all question INSERT statements]
  ''');
  
  // Insert default schedule
  await db.execute('''
    INSERT INTO study_schedule (day_of_week, focus_section) VALUES
    (1, 'QA'),
    (2, 'VARC'),
    (3, 'DILR'),
    (4, 'QA'),
    (5, 'VARC'),
    (6, 'DILR'),
    (7, 'MOCK');
  ''');
  
  print('Database seeded with 100 questions!');
}
```

---

## DATA ENTRY CHECKLIST

### Caselets (10)
- [ ] LR Seating 1 (3 questions) - `c_1.png`
- [ ] LR Seating 2 (3 questions) - `c_2.png`
- [ ] LR Seating 3 (3 questions) - `c_3.png`
- [ ] LR Puzzle 1 (3 questions) - `c_4.png`
- [ ] LR Puzzle 2 (3 questions) - `c_5.png`
- [ ] DI Bar Chart 1 (3 questions) - `c_6.png`
- [ ] DI Bar Chart 2 (3 questions) - `c_7.png`
- [ ] DI Bar Chart 3 (3 questions) - `c_8.png`
- [ ] DI Table 1 (3 questions) - no image
- [ ] DI Table 2 (3 questions) - no image

### QA (40)
- [ ] Number Systems (10) - 5 with diagrams
- [ ] Geometry (10) - 8 with diagrams
- [ ] Algebra (10) - 2 with diagrams
- [ ] Arithmetic (10) - 0 diagrams

### VARC (30)
- [ ] RC Passage 1 (5 questions)
- [ ] RC Passage 2 (5 questions)
- [ ] VA Parajumbles (5)
- [ ] VA Odd One Out (5)
- [ ] VA Para Completion (5)
- [ ] VA Summary (5)

**Total: 100 questions, ~40 images**

---

**Next step:** Start filling in the SQL INSERT statements above by copying questions from your Arun Sharma PDFs!
