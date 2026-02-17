import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/app_utils.dart';
import '../leave/leavehistory.dart';
import 'viewrejoin.dart';

class ReJoinTab extends StatefulWidget {
  const ReJoinTab({super.key});

  @override
  State<ReJoinTab> createState() => _ReJoinTabState();
}

class _ReJoinTabState extends State<ReJoinTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentindex = 0;
  @override
  void initState() {
    _tabController = TabController(initialIndex: 0, vsync: this, length: 2);
    super.initState();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          currentindex = _tabController.index;
        });
      }
    });
  }

  @override
  dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          leading: IconButton(
            icon: Icon(
              CupertinoIcons.back,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: AppUtils.buildNormalText(
            text: "Duty Resumption",
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor:
                Theme.of(context).colorScheme.primary, // 🟦 Theme-based
            labelColor:
                Theme.of(context).colorScheme.primary, // Active tab color
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            onTap: (index) {
              setState(() => currentindex = index);
            },
            tabs: [
              Tab(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Leave History",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8),
                        ),
                  ),
                ),
              ),
              Tab(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Rejoin History",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            LeaveandHistoryPage(),
            ViewRejoin(),
          ],
        ),
      ),
    );
  }
}
