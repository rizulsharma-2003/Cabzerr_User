import 'package:cablow_user/QuickOptions/withdrawScreen.dart';
import 'package:flutter/material.dart';
class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String selectedButton = 'Recent Transition'; // Default selected button

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Your Wallet', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Balance', style: TextStyle(color: Colors.white)),
                          SizedBox(height: 5),
                          Text('₹20000', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        height: 50, // Height of the vertical divider
                        width: 1, // Width of the vertical divider
                        color: Colors.white, // Color of the divider
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Referral Earning', style: TextStyle(color: Colors.white)),
                          SizedBox(height: 5),
                          Text('₹1000', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Withdraw Money?',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  buildButton('Recent Transition', 'assets/image/recent.png', context),
                  SizedBox(width: 10),
                  buildButton('Withdraw', 'assets/image/wallet.png', context),
                  SizedBox(width: 10),
                  buildButton('Referral Friend', 'assets/image/refer.png', context),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text('August 2024', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TransactionItem(
              name: 'Rohit Sharma',
              amount: '+₹1000',
              isCredit: true,
              date: '8 August 2024 at 7:41',
            ),
            TransactionItem(
              name: 'Virat Kohli',
              amount: '-₹1000',
              isCredit: false,
              date: '8 August 2024 at 7:41',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String label, String imagePath, BuildContext context) {
    bool isSelected = selectedButton == label;

    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          selectedButton = label; // Update selected button
        });

        // Navigate to the WithdrawScreen when the "Withdraw" button is clicked
        if (label == 'Withdraw') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WithdrawScreen()),
          );
        }
      },
      icon: Image.asset(
        imagePath,
        height: 24, // Adjust the height and width as needed
        width: 24,
      ),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        side: BorderSide(color: isSelected ? Colors.green : Colors.grey),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Uniform border radius
        ),
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String name;
  final String amount;
  final bool isCredit;
  final String date;

  TransactionItem({
    required this.name,
    required this.amount,
    required this.isCredit,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black), // Add black border
      ),
      padding: const EdgeInsets.all(8.0), // Adjust padding to make space for the border

      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isCredit ? Colors.green : Colors.red,
            child: Text(
              name[0],
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(date, style: TextStyle(color: Colors.grey)),
            ],
          ),
          Spacer(),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCredit ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
