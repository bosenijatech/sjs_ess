import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/pref.dart';
import '../../utils/app_utils.dart';
import '../../utils/sharedprefconstants.dart';


class MyTeamScreen extends StatelessWidget {
  const MyTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: IconThemeData(
          color:
              Theme.of(context).colorScheme.onSurface, // adapts to dark/light
        ),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: AppUtils.buildNormalText(
          text: "My Team",
          color: Theme.of(context).colorScheme.onSurface, // 👈 auto theme color
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTeamCard(
            context: context,
            title: "Head of Department (HOD)",
            name:
                Prefs.getLinemanager(SharefprefConstants.sharedhod).toString(),
            initials: "HO",
            color: Colors.indigo,
          ),
          _buildTeamCard(
            context: context,
            title: "Line Manager",
            name: Prefs.getSupervisor(SharefprefConstants.sharedLineManager)
                .toString(),
            initials: "LM",
            color: Colors.deepPurple,
          ),
          _buildTeamCard(
            context: context,
            title: "Supervisor",
            name: Prefs.gethod(SharefprefConstants.sharedsupervisor).toString(),
            initials: "SP",
            color: Colors.teal,
          ),
          _buildTeamCard(
            context: context,
            title: Prefs.getDesignation(SharefprefConstants.shareddept) ??
                "Employee",
            name:
                Prefs.getFullName(SharefprefConstants.shareFullName) ?? "Staff",
            initials: _getInitials(
              Prefs.getFullName(SharefprefConstants.shareFullName),
            ),
            color: Colors.orangeAccent,
            highlight: true,
          ),
        ],
      ),
    );
  }

  // --- Helper: Beautiful Team Card ---
  Widget _buildTeamCard({
    required BuildContext context, // 👈 Add this
    required String title,
    required String name,
    required String initials,
    required Color color,
    bool highlight = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardColor = theme.cardColor;
    return Card(
      elevation: highlight ? 6 : 3,
      color: cardColor, // 👈 Adaptive card background
      shadowColor: highlight
          ? color.withOpacity(0.3)
          : colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.15),
          child: Text(
            initials,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: highlight
                ? color
                : colorScheme.onSurface.withOpacity(0.8), // 👈 Dynamic color
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            name,
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  colorScheme.onSurface.withOpacity(0.7), // 👈 Theme text color
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        trailing: highlight
            ? Icon(CupertinoIcons.star_fill, color: color, size: 20)
            : Icon(
                CupertinoIcons.person_alt_circle,
                color:
                    colorScheme.primary.withOpacity(0.7), // 👈 Adaptive accent
                size: 20,
              ),
      ),
    );
  }

  // --- Helper: Safe Initials Generator ---
  String _getInitials(String? fullName) {
    if (fullName == null || fullName.isEmpty) return "U";
    final parts = fullName.trim().split(" ");
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class TeamMember {
  final String name;
  final String designation;
  final String? imagePath;
  final String? initials;

  TeamMember(this.name, this.designation, this.imagePath, {this.initials});
}
