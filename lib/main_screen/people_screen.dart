import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/widgets/friend_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Campo de búsqueda
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                placeholder: 'Search',
              ),
            ),

            // Lista de usuarios filtrados
            Expanded(
              child: FutureBuilder<List<UserModel>>(
                future: context
                    .read<AuthenticationProvider>()
                    .getFilteredUsers(
                  currentUser.uid,
                  currentUser.isAdmin,
                ),
                builder: (BuildContext context,
                    AsyncSnapshot<List<UserModel>> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No users found',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                    );
                  }

                  return ListView(
                    children: snapshot.data!.map((UserModel user) {
                      return FriendWidget(
                        friend: user,
                        viewType: FriendViewType.allUsers,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}