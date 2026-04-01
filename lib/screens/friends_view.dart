import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messagex/controllers/friends_controller.dart';
import 'package:messagex/themes/app_theme.dart';
import 'package:messagex/widgets/friend_list_item.dart';

class FriendsView extends GetView<FriendsController> {
  const FriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, size: 28),
            onPressed: () {
              controller.openFriendRequests();
            },
          ),
        ],
      ),
      body:  Column(
          children: [
            SearchBar(controller: controller),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshFriends,
                child: Obx(() {
                  if (controller.isLoading && controller.friends.isNotEmpty) {
                    return MyCircularPrgressIndecator();
                  }
                  if (controller.friends.isEmpty) {
                    return buildEmptyState();
                  } else {
                    return ListView.separated(
                      padding: EdgeInsets.all(16),
                      itemCount: controller.filteredFriends.length,
                      separatorBuilder: (context, index) => SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final friend = controller.filteredFriends[index];
                        return FriendListItem(
                          friend: friend,
                          lastSeenText: controller.getLastSeenText(friend),
                          onTap:()=> controller.startChat(friend),
                          onBlock: ()=>controller.blockFriend(friend),
                          onRemove:()=> controller.removeFriend(friend),
                        );
                      },
                    );
                  }
                }),
              ),
            ),
          ],
        ),
      
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.people_alt_outlined,
                size: 50,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              controller.searchQuery.isNotEmpty
                  ? 'No friends found'
                  : 'No friends yet',
              style: Theme.of(Get.context!).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            Text(
              controller.searchQuery.isNotEmpty
                  ? 'Try a diffrent search term'
                  : 'Add friends to start chat with them',
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (controller.searchQuery.isEmpty) ...[
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: controller.openFriendRequests,
                label: Text('View Frined Requests'),
                icon: Icon(Icons.person_search),
              ),
            ],
          ],
        ),
      ),
    );
  }
}



class MyCircularPrgressIndecator extends StatelessWidget {
  const MyCircularPrgressIndecator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: AppTheme.primaryColor,
        strokeWidth: 2,
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key, required this.controller});

  final FriendsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: TextField(
        onChanged: (value) {
          controller.updateSearchQuery(value);
        },
        decoration: InputDecoration(
          hintText: 'Search Friends',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(
            () => controller.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.updateSearchQuery('');
                    },
                  )
                : const SizedBox.shrink(),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppTheme.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppTheme.borderColor),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),

          filled: true,
          fillColor: AppTheme.cardColor,
        ),
      ),
    );
  }
}
