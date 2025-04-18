import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/widgets/friend_widget.dart';
import 'package:provider/provider.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({
    super.key,
    required this.viewType,
  });

  final FriendViewType viewType;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthenticationProvider>();
    final currentUser = authProvider.userModel!;
    final uid = currentUser.uid;
    final isAdmin = currentUser.isAdmin;

    // Usar getFilteredUsers para obtener usuarios según el tipo
    final future = authProvider.getFilteredUsers(uid, isAdmin);

    return FutureBuilder<List<UserModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No users yet"));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final data = snapshot.data![index];
              return FriendWidget(
                friend: data,
                viewType: viewType,
              );
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}