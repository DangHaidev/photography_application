import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photography_application/core/blocs/theme_provider.dart';
import 'package:photography_application/core/design_systems/design_system_export.dart';
import 'package:photography_application/src/blocs/search/search_bloc.dart';
import 'package:photography_application/src/blocs/search/search_event.dart';
import 'package:photography_application/src/blocs/search/search_state.dart';
import 'package:provider/provider.dart';

import '../profile/profile_id.dart';

class UserSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserSearchBloc>();
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: TextField(
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: (query) {
            bloc.add(SearchUsers(query));
          },
        ),
      ),
      body: BlocBuilder<UserSearchBloc, UserSearchState>(
        builder: (context, state) {
          if (state is UserSearchLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is UserSearchLoaded) {
            final users = state.users;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (_, i) {
                final user = users[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.avatarUrl),
                  ),
                  title: Text(user.name, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                  subtitle: Text(
                    user.bio,
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${user.totalFollowers} follower',
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 12),
                      ),
                      Text(
                        '${user.totalPosts} post',
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                            ProfilePage(user: user),
                      ),
                    );
                    // Có thể mở trang profile
                  },
                );
              },
            );
          } else if (state is UserSearchError) {
            return Center(
              child: Text(state.message, style: TextStyle(color: Colors.red)),
            );
          }
          return Container();
        },
      ),
    );
  }
}
