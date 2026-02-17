
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/expensemodel.dart';
import '../../routenames.dart';
import '../../services/apiservice.dart';
import '../../utils/app_utils.dart';
import '../widgets/custom_button.dart';

class ReimbursementDetails extends StatefulWidget {
  const ReimbursementDetails({super.key});

  @override
  State<ReimbursementDetails> createState() => _ReimbursementDetailsState();
}

class _ReimbursementDetailsState extends State<ReimbursementDetails> {
  bool loading = false;
  late Future<List<ExpenseData>> futureExpenses;
  @override
  void initState() {
    futureExpenses = ApiService.fetchExpenses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 3,
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
          text: "Expense Details",
          color: Theme.of(context).colorScheme.onSurface, // 👈 auto theme color
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ExpenseData>>(
        future: futureExpenses,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No Expense Claim found!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, i) {
                final theme = Theme.of(context);
                final colorScheme = theme.colorScheme;
                final expense = snapshot.data![i];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  color:
                      colorScheme.surface, // 👈 adapts to light/dark background
                  margin: const EdgeInsets.only(bottom: 12),
                  shadowColor: colorScheme.shadow.withOpacity(0.3),
                  child: Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      backgroundColor: colorScheme.surface,
                      collapsedBackgroundColor: colorScheme.surface,
                      iconColor: colorScheme.primary,
                      collapsedIconColor: colorScheme.onSurfaceVariant,
                      title: Text(
                        '${expense.empname} ${expense.classname} - ${expense.internalid}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        '${expense.internalid} • ${expense.paymonth} ${expense.payyear}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primary.withOpacity(0.15),
                        child: Text(
                          expense.empname.isNotEmpty ? expense.empname[0] : '?',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      children: expense.expenseLines.map((line) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? colorScheme.surfaceContainerHighest
                                : Colors
                                    .white, // 👈 light: white, dark: dark surface
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: colorScheme.outline.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// 🧾 Left Column (details)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '📅 ${line.date}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Foreign Amt ${line.forignamount}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Ex.Rate ${line.exchangerate}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),

                              /// 💰 Right Column (amounts)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Net: ${line.amount.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .green, // still readable both modes
                                    ),
                                  ),
                                  Text(
                                    'Tax: ${line.taxamount.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                  Text(
                                    'Gross: ${line.grossamount.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      persistentFooterButtons: [
        CustomButton(
            onPressed: () async {
              final result =
                  await Navigator.pushNamed(context, RouteNames.reimapply);

              if (result == true) {
                setState(() {
                  futureExpenses = ApiService.fetchExpenses(); // No await here
                });
              }
            },
            name: "Click to Apply Expense",
            fontSize: 14,
            circularvalue: 30),
      ],
    );
  }
}
