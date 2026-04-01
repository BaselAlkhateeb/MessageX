import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messagex/controllers/users_list_controller.dart';
import 'package:messagex/themes/app_theme.dart';
import 'package:messagex/widgets/user_list_item.dart';

class FindPeopleView extends GetView<UsersListController> {
  const FindPeopleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Find Frinds')),

      body: Column(
        children: [
          buildSearchBar(),

          Expanded(
            child: Obx(() {
              if (controller.filteredUsers.isEmpty) {
                return buildEmptyState();
              } else {
                return ListView.separated(
                  padding: EdgeInsets.all(16),

                  separatorBuilder: (_, index) => SizedBox(height: 8),
                  itemCount: controller.filteredUsers.length,

                  itemBuilder: (_, index) {
                    final user = controller.filteredUsers[index];
                    return UserListItem(
                      user: user,
                      onTap: () => controller.handleRelationshipAction(user),
                      controller: controller,
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).scaffoldBackgroundColor,
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: (value) {
          controller.updateSearchQuery(value);
        },
        decoration: InputDecoration(
          hintText: 'search people',
          prefixIcon: Icon(Icons.search),
          suffixIcon: Obx(
            () => controller.searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: controller.clearSearch,
                    child: Icon(Icons.clear),
                  )
                : SizedBox.shrink(),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          filled: true,
          fillColor: AppTheme.cardColor,
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
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
                  ? 'No results found'
                  : 'No people found',
              style: Theme.of(Get.context!).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            Text(
              controller.searchQuery.isNotEmpty
                  ? 'Try a diffrent search term'
                  : 'All users will show here',
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
