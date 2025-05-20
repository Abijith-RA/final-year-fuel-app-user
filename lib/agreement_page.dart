import 'package:flutter/material.dart';

class AgreementPage extends StatefulWidget {
  @override
  _AgreementPageState createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  bool isChecked = false;

  void updateAgreementStatus(bool status) {
    setState(() {
      isChecked = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 50,
                  ),
                  SizedBox(height: 15),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    child: Text(
                      "Important Notice",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  SizedBox(height: 15),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    child: Text(
                      "Fuel is a hazardous substance, handle with care!",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    child: Text(
                      "By agreeing, you acknowledge all terms and risks.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => TermsPage(updateAgreementStatus),
                        ),
                      );
                      if (result != null && result) {
                        updateAgreementStatus(true);
                      }
                    },
                    child: Text(
                      "Read Terms & Conditions",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            side: BorderSide(color: Colors.orange, width: 2),
                            foregroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed:
                              isChecked
                                  ? () {
                                    Navigator.pushNamed(context, '/update');
                                  }
                                  : null,
                          child: Text("Agree"),
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            side: BorderSide(color: Colors.red, width: 2),
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/warning');
                          },
                          child: Text("Cancel"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TermsPage extends StatefulWidget {
  final Function(bool) updateAgreementStatus;
  TermsPage(this.updateAgreementStatus);

  @override
  _TermsPageState createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool isAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 10),
              Icon(Icons.description, color: Colors.orange, size: 50),
              SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (String term in _termsList()) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            term,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                      Row(
                        children: [
                          Checkbox(
                            value: isAgreed,
                            activeColor: Colors.orange,
                            checkColor: Colors.black,
                            onChanged: (value) {
                              setState(() {
                                isAgreed = value!;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              "I agree to the terms and conditions.",
                              style: TextStyle(color: Colors.white),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isAgreed
                            ? () {
                              widget.updateAgreementStatus(true);
                              Navigator.pop(context, true);
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Accept & Go Back"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _termsList() {
    return [
      "1. Fuel purchased through this app is only for vehicle use, not for storage in any containers or bottles.",
      "2. Misuse of fuel for harmful activities, including self-harm or illegal acts, is strictly prohibited and not our responsibility.",
      "3. Fuel cannot be resold after purchase; only fill the fuel in the vehicle.",
      "4. The company is not responsible for any accidents, injuries, or damages caused by improper use of fuel.",
      "5. The user must ensure fuel is received directly into their vehicle and not into any external storage.",
      "6. Fuel orders cannot be modified or canceled once confirmed; ensure details are correct before placing an order.",
      "7. The app is not liable for fuel quality issues unless reported within 24 hours of delivery.",
      "8. Unauthorized resale or transfer of fuel to third parties is strictly prohibited.",
      "9. Customers must comply with all legal requirements regarding fuel transportation and handling.",
      "10. Tampering with fuel delivery systems is illegal and will be reported to authorities.",
      "11. The company reserves the right to block accounts found violating these terms.",
      "12. Fuel deliveries must be received by the registered user or an authorized person only.",
      "13. The app does not provide emergency fuel supply services; plan your refueling accordingly.",
      "14. Fuel cannot be used for experimental, industrial, or unauthorized business purposes.",
      "15. The company is not liable for consequences arising from improper fuel storage or handling.",
      "16. Any disputes regarding fuel purchases must be reported through official customer support channels.",
    ];
  }
}
