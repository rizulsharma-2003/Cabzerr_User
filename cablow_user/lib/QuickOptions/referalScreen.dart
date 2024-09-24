import 'package:flutter/material.dart';


class ReferralScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the size of the screen
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Referral & Earns', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,

      ),
      body: SingleChildScrollView(

        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Adjust image size based on screen width
              Image.asset(
                'assets/image/referandearnn.png',
                height: screenHeight * 0.3,
                width: screenWidth * 1.5,
                fit: BoxFit.contain,
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: EdgeInsets.all(screenHeight * 0.02),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Refer and Earn!',
                        style: TextStyle(
                          fontSize: screenHeight * 0.03,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: screenHeight * 0.02,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: 'Invite Your Friends: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: 'Share the learning experience! Refer your friends to join our live classes.',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: screenHeight * 0.02,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: 'Earn Rewards: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: 'For every successful referral, earn exciting rewards or discounts on your next purchase.',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Image.asset(
                                'assets/image/youget.png',
                                height: screenHeight * 0.07,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                '₹100 Wallet',
                                style: TextStyle(
                                  fontSize: screenHeight * 0.02,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Image.asset(
                                'assets/image/friendget.png',
                                height: screenHeight * 0.07,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                '₹100 Wallet',
                                style: TextStyle(
                                  fontSize: screenHeight * 0.02,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.015,
                                horizontal: screenWidth * 0.04,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'JSAFSAFVAFB',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: screenHeight * 0.022,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          IconButton(
                            icon: Icon(Icons.copy, color: Colors.black),
                            iconSize: screenHeight * 0.03,
                            onPressed: () {
                              // Handle copy action
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Handle share action
                        },
                        icon: Icon(Icons.share, size: screenHeight * 0.03),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.012,
                            horizontal:screenWidth * 0.15 ,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        label: Text(
                          'Share Invite Link',
                          style: TextStyle(fontSize: screenHeight * 0.022),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
