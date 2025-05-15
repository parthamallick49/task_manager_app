// lib/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  CustomAppBar({required this.title, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 24, // Increased font size for a more impactful title
          fontWeight: FontWeight.w600, // Slightly lighter than bold for better flow
          color: Colors.black87, // Softer black color for text
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 6.0, // Slightly reduced shadow for a more subtle effect
      iconTheme: IconThemeData(color: Colors.black87),
      leading: showBackButton
          ? IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      )
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20), // Slightly more rounded corners for a softer look
          bottomRight: Radius.circular(20),
        ),
      ),
      toolbarHeight: 90, // Increased height for more spacing and padding
      centerTitle: true, // Centering the title to make it look more balanced
      shadowColor: Colors.black.withOpacity(0.1), // Soft shadow for better contrast
      actions: showBackButton
          ? [] // If the back button is present, no additional icons in the actions
          : [
        // Add any other icons in the app bar here if needed
      ],
    )
    ;
  }

  @override
  Size get preferredSize => Size.fromHeight(90); // Adjusted height to match the new padding
}
