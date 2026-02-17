// import 'package:alsaqr/utils/appcolor.dart';
// import 'package:flutter/material.dart';

// class AppTheme {
//   // ☀️ Light Theme
//   static final ThemeData lightTheme = ThemeData(
//     brightness: Brightness.light,
//     scaffoldBackgroundColor: Colors.grey[50],
//     primaryColor: Appcolor.primarycolor,
//     chipTheme: const ChipThemeData(
//       checkmarkColor: Colors.white, // 👈 old property name
//     ),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.black87,
//       elevation: 1,
//       titleTextStyle: TextStyle(
//         color: Colors.black87,
//         fontWeight: FontWeight.w600,
//         fontSize: 18,
//       ),
//       iconTheme: IconThemeData(color: Colors.black87),
//     ),
//     cardColor: Colors.white,
//     textTheme: const TextTheme(
//       bodyMedium: TextStyle(color: Colors.black87, fontSize: 14),
//       bodySmall: TextStyle(color: Colors.black54, fontSize: 12),
//       titleMedium: TextStyle(
//         color: Colors.black,
//         fontWeight: FontWeight.bold,
//         fontSize: 16,
//       ),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Appcolor.primarycolor, // brown color
//         foregroundColor: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     ),
//   );

//   // 🌙 Dark Theme
//   static final ThemeData darkTheme = ThemeData(
//     brightness: Brightness.dark,
//     scaffoldBackgroundColor: const Color(0xFF121212),
//     primaryColor: Colors.tealAccent,
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Color(0xFF1F1F1F),
//       foregroundColor: Colors.white,
//       elevation: 0,
//       titleTextStyle: TextStyle(
//         color: Colors.white,
//         fontWeight: FontWeight.w600,
//         fontSize: 18,
//       ),
//       iconTheme: IconThemeData(color: Colors.white),
//     ),
//     cardColor: const Color(0xFF1E1E1E),
//     textTheme: const TextTheme(
//       bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
//       bodySmall: TextStyle(color: Colors.white54, fontSize: 12),
//       titleMedium: TextStyle(
//         color: Colors.white,
//         fontWeight: FontWeight.bold,
//         fontSize: 16,
//       ),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.tealAccent,
//         foregroundColor: Colors.black,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(8)),
//         ),
//       ),
//     ),
//   );
//   // static final ThemeData lightTheme = ThemeData(
//   //   useMaterial3: true, // 👈 keep Material 3 enabled (modern design)
//   //   brightness: Brightness.light,
//   //   colorScheme: ColorScheme.light(
//   //     primary: Appcolor.primarycolor, // main app accent
//   //     secondary: Appcolor.secondarycolor,
//   //     surface: Colors.white,
//   //     surfaceContainerHighest: Colors.grey[200]!,
//   //     onSurface: Colors.black87,
//   //     outline: Colors.grey[400]!,
//   //     shadow: Colors.black12,
//   //   ),
//   //   cardTheme: CardThemeData(
//   //     color: Colors.white,
//   //     elevation: 4, // 👈 makes shadow visible
//   //     margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//   //     shape: RoundedRectangleBorder(
//   //       borderRadius: BorderRadius.circular(10),
//   //     ),
//   //     shadowColor: Colors.black.withOpacity(0.15),
//   //     surfaceTintColor:
//   //         Colors.transparent, // 👈 crucial for visible elevation in Material 3
//   //   ),
//   //   dividerColor: Colors.grey.shade300,
//   //   scaffoldBackgroundColor: Appcolor.backgroundColor,
//   //   appBarTheme: const AppBarTheme(
//   //     backgroundColor: Colors.white,
//   //     foregroundColor: Colors.black87,
//   //   ),

//   //   inputDecorationTheme: InputDecorationTheme(
//   //     filled: true,
//   //     fillColor: Colors.grey[100], // 👈 fill color for TextField
//   //     border: const OutlineInputBorder(
//   //         borderRadius: BorderRadius.all(Radius.circular(8))),
//   //     enabledBorder: const OutlineInputBorder(
//   //       borderSide: BorderSide(color: Colors.black26),
//   //     ),
//   //     focusedBorder: OutlineInputBorder(
//   //       borderSide: BorderSide(color: Appcolor.primarycolor),
//   //     ),
//   //   ),
//   // );

//   // static final ThemeData darkTheme = ThemeData(
//   //   brightness: Brightness.dark,
//   //   colorScheme: ColorScheme.dark(
//   //     primary: Colors.tealAccent,
//   //     secondary: Appcolor.secondarycolor,
//   //     surface: const Color(0xFF1E1E1E),
//   //     surfaceContainerHighest: const Color(0xFF2A2A2A),
//   //     onSurface: Colors.white70,
//   //     outline: Colors.white10,
//   //     shadow: Colors.black,
//   //   ),
//   //   scaffoldBackgroundColor: const Color(0xFF121212),
//   //   appBarTheme: const AppBarTheme(
//   //     backgroundColor: Color(0xFF1F1F1F),
//   //     foregroundColor: Colors.white,
//   //   ),
//   //   inputDecorationTheme: const InputDecorationTheme(
//   //     filled: true,
//   //     fillColor: Color(0xFF2A2A2A), // 👈 visible dark fill color
//   //     border: OutlineInputBorder(
//   //         borderRadius: BorderRadius.all(Radius.circular(8))),
//   //     enabledBorder: OutlineInputBorder(
//   //       borderSide: BorderSide(color: Colors.white24),
//   //     ),
//   //     focusedBorder: OutlineInputBorder(
//   //       borderSide: BorderSide(color: Colors.tealAccent),
//   //     ),
//   //   ),
//   // );
// }



import 'package:flutter/material.dart';


import '../../utils/appcolor.dart';

class AppTheme {
  // ===================== ☀️ LIGHT THEME =====================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // 🎨 Color Scheme (PRIMARY SET HERE)
    colorScheme: ColorScheme.fromSeed(
      seedColor: Appcolor.primarycolor, // Brown primary
      brightness: Brightness.light,
    ),

    scaffoldBackgroundColor: Colors.grey.shade50,

    // 🔝 AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 1,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      iconTheme: IconThemeData(color: Colors.black87),
    ),

    // 🧾 Card
  cardTheme: CardThemeData(
  color: Colors.white,
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
),


    // 📝 Text Theme
    textTheme: const TextTheme(
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.black54,
      ),
    ),

    // 🔘 Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Appcolor.primarycolor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // 🏷️ Chip
    chipTheme: ChipThemeData(
      backgroundColor: Appcolor.primarycolor.withOpacity(0.1),
      selectedColor: Appcolor.primarycolor,
      checkmarkColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.black),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    ),
  );

  // ===================== 🌙 DARK THEME =====================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // 🎨 Color Scheme (PRIMARY SET HERE)
    colorScheme: ColorScheme.fromSeed(
      seedColor: Appcolor.primarycolor,
      brightness: Brightness.dark,
    ),

    scaffoldBackgroundColor: const Color(0xFF121212),

    // 🔝 AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // 🧾 Card
 cardTheme: CardThemeData(
  color: const Color(0xFF1E1E1E),
  elevation: 1,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
),


    // 📝 Text Theme
    textTheme: const TextTheme(
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.white70,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.white54,
      ),
    ),

    // 🔘 Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Appcolor.primarycolor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // 🏷️ Chip
    chipTheme: ChipThemeData(
      backgroundColor: Appcolor.primarycolor.withOpacity(0.25),
      selectedColor: Appcolor.primarycolor,
      checkmarkColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.white),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    ),
  );
}
