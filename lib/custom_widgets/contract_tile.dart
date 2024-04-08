import 'package:flutter/material.dart';
import 'package:smashhit_ui/data/models.dart';
import 'package:smashhit_ui/data/data_provider.dart';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';


class ContractTile extends StatefulWidget {
  final Function(int, [String]) changeScreen;
  final Function() refresh;
  final Contract? contract;
  final String? userId;
  final int? index;

  ContractTile(this.changeScreen, this.refresh, this.contract, this.userId, this.index);

  @override
  _ContractTileState createState() => _ContractTileState();
}



class _ContractTileState extends State<ContractTile> {
  DataProvider dataProvider = new DataProvider();
  List<Signature> signatures = [];
  bool _hasSigned = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    fetchAllSignatures();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Material(
      child: InkWell(
        //TODO: fix splash effect, currently it is behind the container
        splashColor: Colors.white,
        child: _isSmallScreen(screenWidth)
            ? smallContractTile()
            : bigContractTile(),
        onTap: () {
          widget.changeScreen(2, '${widget.contract!.id!}');
        },
      ),
    );
  }

  bool _isSmallScreen(double width) {
    if (width <= 500.0) {
      return true;
    }
    return false;
  }

  Container bigContractTile() {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
      width: 125,
      //height: height / 8,
      height: 75,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black45,
            blurRadius: 2.0,
            spreadRadius: 1.0,
            offset: Offset(2.0, 2.0))
      ]),
      child: Center(
        child: Row(
          children: [
            Expanded(child: Center(child: Text("${widget.index}."))),
            Expanded(flex: 1, child: Align(alignment: Alignment.center, child: Icon(Icons.folder_shared, size: 25))),
            Expanded(
                flex: 8,
                child: Text('${widget.contract!.id!}',
                    overflow: TextOverflow.ellipsis)),
            Expanded(flex: 4, child: Text("Contracting Party")),
            Expanded(
                flex: 6,
                child: Text('${widget.contract!.purpose}',
                    overflow: TextOverflow.ellipsis)),
            Expanded(flex: 4, child: contractSignedIcon()),
            Expanded(flex: 2, child: contractIconByStatus(widget.contract!.status!)),
            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  editContractButton(widget.contract!.id!),
                  deleteContractButton(widget.contract!.id!),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                checkConsistency(widget.contract!.id!),

            

                
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container smallContractTile() {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
      width: 125,
      //height: height / 8,
      height: 150,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black45,
            blurRadius: 2.0,
            spreadRadius: 1.0,
            offset: Offset(2.0, 2.0))
      ]),
      child: Center(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(Icons.folder_shared, size: 75),
                  SizedBox(
                      width: 200,
                      child: Text('${widget.contract!.id!}',
                          overflow: TextOverflow.ellipsis))
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                decoration:
                    BoxDecoration(border: Border(top: BorderSide(width: 1))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Status:"),
                          contractIconByStatus(
                              widget.contract!.status!),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                          left: BorderSide(width: 1),
                        )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("Actions:"),
                            editContractButton(widget.contract!.id!),
                            deleteContractButton(widget.contract!.id!),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget contractSignedIcon() {
    int numSignatures = widget.contract!.signatures.length;
    int numContractors = widget.contract!.contractors.length;

    bool allSigned = numSignatures == numContractors;

    return Container(
        child: _isLoading
            ? CircularProgressIndicator()
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("$numSignatures/$numContractors"),
                  SizedBox(width: 5),
                  hasSignedIcon(allSigned)],
              ));
  }

  Future<void> fetchAllSignatures() async {
    _toggleLoading();
    widget.contract!.signatures.forEach((element) async {
      Signature signature = await dataProvider.fetchSignatureById(element);
      signatures.add(signature);
      if (signature.contractorId == widget.userId) {
        setState(() {
          _hasSigned = true;
        });
      }
    });
    _toggleLoading();
  }

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  Widget hasSignedIcon(bool allSigned) {
    if (_hasSigned) {
      return Tooltip(
        message: "You have signed this contract.",
        child: allSigned
            ? Icon(Icons.done_all, color: Colors.green, size: 30)
            : Icon(Icons.done, color: Colors.green, size: 30)
      );
    } else {
      return Tooltip(
        message: "Please view this contract and confirm it with your signature.",
        child: Icon(Icons.priority_high, color: Colors.red, size: 30),
      );
    }
  }

  Tooltip contractIconByStatus(String status) {
    if (status.contains("Created") || status.contains("created")) {
      return Tooltip(
          message: "The contract has recently been created.",
          child: Icon(Icons.new_releases, color: Colors.blue, size: 30));
    } else if (status.contains("Pending") || status.contains("pending")) {
      return Tooltip(
          message: "The contract is still awaiting signatures.",
          child: Icon(Icons.pending, color: Colors.grey, size: 30));
    } else if (status.contains("Signed") || status.contains("signed")) {
      return Tooltip(
          message: "The contract has been signed by all parties.",
          child: Icon(Icons.thumb_up, color: Colors.blue, size: 30));
    } else if (status.contains("Terminated") || status.contains("terminated")) {
      return Tooltip(
          message: "The contract has been terminated.",
          child: Icon(Icons.do_not_disturb, color: Colors.yellow, size: 30));
    } else if (status.contains("Renewed") || status.contains("renewed")) {
      return Tooltip(
          message: "The contract has been renewed.",
          child: Icon(Icons.history, color: Colors.blue, size: 30));
    } else if (status.contains("Updated") || status.contains("updated")) {
      return Tooltip(
          message: "The contract has been renewed.",
          child: Icon(Icons.update, color: Colors.blue, size: 30));
    } else if (status.contains("Violated") || status.contains("violated")) {
      return Tooltip(
          message: "An issue in the contract has been reported.",
          child: Icon(Icons.report, color: Colors.red, size: 30));
    } else if (status.contains("Expired") || status.contains("expired")) {
      return Tooltip(
          message: "The contract has expired.",
          child: Icon(Icons.hourglass_bottom, color: Colors.blue, size: 30));
    } else {
      return Tooltip(
          message:
          "The contract's status could not be read. Please review the contract.",
          child: Icon(Icons.error, color: Colors.blue, size: 30));
    }
  }

  Widget editContractButton(String contractId) {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(Icons.edit, size: 30),
      onPressed: () {
        widget.changeScreen(6, contractId);
      },
    );
  }

    List<String> parseTextIntoAnswers() {
   
    
   

    
//     String text = '''Solving...
// Answer: 1
// actualTarget("base_contb2c_570045be-7248-11ed-b6c2-0242ac150003",schema_CCV1stScenarioShape) add(base_hasContractCategory("base_contb2c_570045be-7248-11ed-b6c2-0242ac150003","base_categoryBusinessToConsumer"))
// Optimization: 0 1
// Answer: 2
// actualTarget("base_contb2c_570045be-7248-11ed-b6c2-0242ac150003",schema_CCV1stScenarioShape) add(base_hasContractCategory("base_contb2c_570045be-7248-11ed-b6c2-0242ac150003","base_categoryBusinessToBusiness"))
// Optimization: 0 1
// OPTIMUM FOUND

// Models       : 4
//   Optimum    : yes
//   Optimal    : 2
// Optimization : 0 1
// Calls        : 1
// Time         : 0.004s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
// CPU Time     : 0.004s'''
// ;

  

 List<String> texts = [
    '''Solving...
    Answer: 1
    actualTarget("base_contb2c_04f04514-545f-11ed-9e89-0242ac150003",schema_CCV1stScenarioShape) add(base_hasContractCategory("base_contb2c_04f04514-545f-11ed-9e89-0242ac150003","base_categoryBusinessToConsumer"))
    Optimization: 0 1
    Answer: 2
    actualTarget("base_contb2c_04f04514-545f-11ed-9e89-0242ac150003",schema_CCV1stScenarioShape) add(base_hasContractCategory("base_contb2c_04f04514-545f-11ed-9e89-0242ac150003","base_categoryBusinessToBusiness"))
    Optimization: 0 1
    OPTIMUM FOUND

    Models       : 4
      Optimum    : yes
      Optimal    : 2
    Optimization : 0 1
    Calls        : 1
    Time         : 0.004s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
    CPU Time     : 0.004s''',



'''Solving...
Answer: 1
actualTarget("_contb2c_4a2e66a2-de1e-11ee-8bff-0242ac1c0002",_contractStatusShape) del(_hasContractCategory("_contb2c_4a2e66a2-de1e-11ee-8bff-0242ac1c0002","_categoryBusinessToBusiness"))
Optimization: 0 1
Answer: 2
actualTarget("_contb2c_4a2e66a2-de1e-11ee-8bff-0242ac1c0002",_contractStatusShape) del(_hasContractCategory("_contb2c_4a2e66a2-de1e-11ee-8bff-0242ac1c0002","_categoryBusinessToConsumer"))
Optimization: 0 1
OPTIMUM FOUND

Models       : 3
  Optimum    : yes
  Optimal    : 2
Optimization : 0 1
Calls        : 1
Time         : 0.004s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.005s
Threads      : 3        (Winner: 1)''',
    '''Solving...
Answer: 1
actualTarget("base_contb2c_f63cb4fa-e2b3-11ee-b956-0242ac1c0002",_contractStatusShape) del(base_hasContractStatus("base_contb2c_f63cb4fa-e2b3-11ee-b956-0242ac1c0002","_statusPending"))
Optimization: 0 1
Answer: 2
actualTarget("base_contb2c_f63cb4fa-e2b3-11ee-b956-0242ac1c0002",_contractStatusShape) del(base_hasContractStatus("base_contb2c_f63cb4fa-e2b3-11ee-b956-0242ac1c0002","_statusCreated"))
Optimization: 0 1
OPTIMUM FOUND

Models       : 4
  Optimum    : yes
  Optimal    : 2
Optimization : 0 1
Calls        : 1
Time         : 0.021s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.005s''',


'''Solving...
Answer: 1
actualTarget("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002",_contractCategoryShape) del(_hasContractCategory("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002","_categoryBusinessToConsumers")) add(_hasContractCategory("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002","_categoryBusinessToConsumer"))
Optimization: 0 2 1
Answer: 2
actualTarget("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002",_contractCategoryShape) del(_hasContractCategory("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002","_categoryBusinessToConsumers")) add(_hasContractCategory("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002","_categoryBusinessToConsumer"))
Optimization: 0 2 1
Answer: 3
actualTarget("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002",_contractCategoryShape) del(_hasContractCategory("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002","_categoryBusinessToConsumers")) add(_hasContractCategory("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002","_categoryBusinessToConsumer"))
Optimization: 0 2 1
Answer: 4
actualTarget("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002",_contractCategoryShape) del(_hasContractCategory("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002","_categoryBusinessToConsumers")) add(_hasContractCategory("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002","_categoryBusinessToConsumer"))
Optimization: 0 2 1
Answer: 5
actualTarget("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002",_contractCategoryShape) del(_hasContractCategory("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002","_categoryBusinessToConsumers")) add(_hasContractCategory("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002","_categoryBusinessToBusiness"))
Optimization: 0 2 1
Answer: 6
actualTarget("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002",_contractCategoryShape) del(_hasContractCategory("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002","_categoryBusinessToConsumers")) add(_hasContractCategory("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002","_categoryBusinessToBusiness"))
Optimization: 0 2 1
Answer: 7
actualTarget("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002",_contractCategoryShape) del(_hasContractCategory("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002","_categoryBusinessToConsumers")) add(_hasContractCategory("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002","_categoryBusinessToBusiness"))
Optimization: 0 2 1
Answer: 8
actualTarget("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002",_contractCategoryShape) del(_hasContractCategory("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002","_categoryBusinessToConsumers")) add(_hasContractCategory("_contb2c_90e29d48-e6de-11ee-a88e-0242ac1c0002","_categoryBusinessToBusiness"))
Optimization: 0 2 1
OPTIMUM FOUND

Models       : 10
  Optimum    : yes
  Optimal    : 8
Optimization : 0 2 1
Calls        : 1
Time         : 0.009s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.010s
Threads      : 3        (Winner: 0)''',

'''Solving...
Answer: 1
actualTarget("_contb2c_7794b096-e6df-11ee-97db-0242ac1c0002",_endDateShape) del(_hasEndDate("_contb2c_7794b096-e6df-11ee-97db-0242ac1c0002","2024_07_07 10:38:07.617000+00:00"))
Optimization: 0 1
Answer: 2
actualTarget("_contb2c_7794b096-e6df-11ee-97db-0242ac1c0002",_endDateShape) del(_hasEndDate("_contb2c_7794b096-e6df-11ee-97db-0242ac1c0002","2023_07_07 10:38:07.617000+00:00"))
Optimization: 0 1
OPTIMUM FOUND

Models       : 3
  Optimum    : yes
  Optimal    : 2
Optimization : 0 1
Calls        : 1
Time         : 0.006s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.006s
Threads      : 3        (Winner: 1)''',

'''Solving...
Answer: 1
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_removeContractStatusShape) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusPending")) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusFulfilled"))
Optimization: 0 2 0
Answer: 2
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_removeContractStatusShape) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusPending")) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusFulfilled"))
Optimization: 0 2 0
Answer: 3
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_removeContractStatusShape) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusPending")) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusViolated"))
Optimization: 0 2 0
Answer: 4
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_removeContractStatusShape) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusPending")) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusFulfilled"))
Optimization: 0 2 0
Answer: 5
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_removeContractStatusShape) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusPending")) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusFulfilled"))
Optimization: 0 2 0
Answer: 6
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_removeContractStatusShape) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusFulfilled")) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusViolated"))
Optimization: 0 2 0
Answer: 7
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_removeContractStatusShape) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusPending")) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusViolated"))
Optimization: 0 2 0
Answer: 8
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_removeContractStatusShape) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusFulfilled")) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusViolated"))
Optimization: 0 2 0
Answer: 9
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_removeContractStatusShape) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusFulfilled")) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusViolated"))
Optimization: 0 2 0
Answer: 10
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_removeContractStatusShape) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusFulfilled")) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusViolated"))
Optimization: 0 2 0
Answer: 11
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_removeContractStatusShape) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusPending")) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusViolated"))
Optimization: 0 2 0
Answer: 12
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_removeContractStatusShape) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusPending")) del(_hasContractStatus("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_statusViolated"))
Optimization: 0 2 0
OPTIMUM FOUND

Models       : 13
  Optimum    : yes
  Optimal    : 12
Optimization : 0 2 0
Calls        : 1
Time         : 0.027s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.012s
Threads      : 3        (Winner: 2) ''',
'''Solving...
Answer: 1
actualTarget("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003",_contractStatusShape) del(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusUnknown")) add(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusFulfilled"))
Optimization: 0 2 1
Answer: 2
actualTarget("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003",_contractStatusShape) del(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusUnknown")) add(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusFulfilled"))
Optimization: 0 2 1
Answer: 3
actualTarget("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003",_contractStatusShape) del(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusUnknown")) add(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusPending"))
Optimization: 0 2 1
Answer: 4
actualTarget("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003",_contractStatusShape) del(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusUnknown")) add(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusPending"))
Optimization: 0 2 1
Answer: 5
actualTarget("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003",_contractStatusShape) del(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusUnknown")) add(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusPending"))
Optimization: 0 2 1
Answer: 6
actualTarget("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003",_contractStatusShape) del(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusUnknown")) add(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusPending"))
Optimization: 0 2 1
Answer: 7
actualTarget("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003",_contractStatusShape) del(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusUnknown")) add(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusFulfilled"))
Optimization: 0 2 1
Answer: 8
actualTarget("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003",_contractStatusShape) del(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusUnknown")) add(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusFulfilled"))
Optimization: 0 2 1
Answer: 9
actualTarget("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003",_contractStatusShape) del(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusUnknown")) add(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusViolated"))
Optimization: 0 2 1
Answer: 10
actualTarget("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003",_contractStatusShape) del(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusUnknown")) add(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusViolated"))
Optimization: 0 2 1
Answer: 11
actualTarget("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003",_contractStatusShape) del(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusUnknown")) add(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusViolated"))
Optimization: 0 2 1
Answer: 12
actualTarget("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003",_contractStatusShape) del(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusUnknown")) add(_hasContractStatus("_contb2c_d3769ce4-545a-11ed-a573-0242ac150003","_statusViolated"))
Optimization: 0 2 1
OPTIMUM FOUND

Models       : 14
  Optimum    : yes
  Optimal    : 12
Optimization : 0 2 1
Calls        : 1
Time         : 0.010s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.011s
Threads      : 3        (Winner: 2)''',
'''Solving...
Answer: 1
actualTarget("_contb2c_867a7260-f4d8-11ee-a348-0242ac1c0002",_effectiveDateShape) del(fibo_fnd_agr_ctr_hasEffectiveDate("_contb2c_867a7260-f4d8-11ee-a348-0242ac1c0002","2022_09_07 10:38:07.617000+00:00"))
Optimization: 0 1
Answer: 2
actualTarget("_contb2c_867a7260-f4d8-11ee-a348-0242ac1c0002",_effectiveDateShape) del(fibo_fnd_agr_ctr_hasEffectiveDate("_contb2c_867a7260-f4d8-11ee-a348-0242ac1c0002","2023_09_07 10:38:07.617000+00:00"))
Optimization: 0 1
OPTIMUM FOUND

Models       : 3
  Optimum    : yes
  Optimal    : 2
Optimization : 0 1
Calls        : 1
Time         : 0.004s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.005s
Threads      : 3        (Winner: 1)''',
'''Solving...
Answer: 1
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_contractMediumShape) del(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_writtenn")) add(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_written"))
Optimization: 0 2 1
Answer: 2
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_contractMediumShape) del(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_writtenn")) add(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_written"))
Optimization: 0 2 1
Answer: 3
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_contractMediumShape) del(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_writtenn")) add(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_written"))
Optimization: 0 2 1
Answer: 4
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_contractMediumShape) del(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_writtenn")) add(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_transferable"))
Optimization: 0 2 1
Answer: 5
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_contractMediumShape) del(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_writtenn")) add(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_written"))
Optimization: 0 2 1
Answer: 6
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_contractMediumShape) del(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_writtenn")) add(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_transferable"))
Optimization: 0 2 1
Answer: 7
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_contractMediumShape) del(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_writtenn")) add(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_verbal"))
Optimization: 0 2 1
Answer: 8
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_contractMediumShape) del(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_writtenn")) add(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_transferable"))
Optimization: 0 2 1
Answer: 9
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_contractMediumShape) del(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_writtenn")) add(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_verbal"))
Optimization: 0 2 1
Answer: 10
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_contractMediumShape) del(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_writtenn")) add(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_verbal"))
Optimization: 0 2 1
Answer: 11
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_contractMediumShape) del(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_writtenn")) add(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_verbal"))
Optimization: 0 2 1
Answer: 12
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_contractMediumShape) del(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_writtenn")) add(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_transferable"))
Optimization: 0 2 1
Answer: 13
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_contractMediumShape) del(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_writtenn")) add(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_mutual"))
Optimization: 0 2 1
Answer: 14
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_contractMediumShape) del(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_writtenn")) add(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_mutual"))
Optimization: 0 2 1
Answer: 15
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_contractMediumShape) del(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_writtenn")) add(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_mutual"))
Optimization: 0 2 1
Answer: 16
actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_contractMediumShape) del(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_writtenn")) add(_contractType("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","_mutual"))
Optimization: 0 2 1
OPTIMUM FOUND

Models       : 18
  Optimum    : yes
  Optimal    : 16
Optimization : 0 2 1
Calls        : 1
Time         : 0.010s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.011s
Threads      : 3        (Winner: 2)''',
'''Solving...
Answer: 1
actualTarget("_contb2c_08ca8b62-e6e0-11ee-8979-0242ac1c0002",_contractStatusShape) del(_contractID("_contb2c_08ca8b62-e6e0-11ee-8979-0242ac1c0002","contb2c_87c2cf26_2f51_11ed_be7d_3f8589292a29"))
Optimization: 0 1
Answer: 2
actualTarget("_contb2c_08ca8b62-e6e0-11ee-8979-0242ac1c0002",_contractStatusShape) del(_contractID("_contb2c_08ca8b62-e6e0-11ee-8979-0242ac1c0002","contb2c_87c2cf26_23f51_11ed_be7d_3f8589292a29"))
Optimization: 0 1
OPTIMUM FOUND

Models       : 3
  Optimum    : yes
  Optimal    : 2
Optimization : 0 1
Calls        : 1
Time         : 0.005s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.005s
Threads      : 3        (Winner: 1)''',
// '''Solving...
// Answer: 1
// actualTarget("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002",_contractContractorShape) add(_hasContractors("_contb2c_536117d4-e2b4-11ee-bdde-0242ac1c0002","5323"))
// Optimization: 0 1
// OPTIMUM FOUND

// Models       : 2
//   Optimum    : yes
// Optimization : 0 1
// Calls        : 1
// Time         : 0.006s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
// CPU Time     : 0.006s
// Threads      : 3        (Winner: 2)''',
'''Solving...
Answer: 1
actualTarget("_contb2c_77d8a6f8-f331-11ee-8f65-0242ac1c0002",_removeContractCategory) del(_hasContractCategory("_contb2c_77d8a6f8-f331-11ee-8f65-0242ac1c0002","_categoryBusinessToBusiness"))
Optimization: 0 1
Answer: 2
actualTarget("_contb2c_77d8a6f8-f331-11ee-8f65-0242ac1c0002",_removeContractCategory) del(_hasContractCategory("_contb2c_77d8a6f8-f331-11ee-8f65-0242ac1c0002","_categoryBusinessToConsumer"))
Optimization: 0 1
OPTIMUM FOUND

Models       : 3
  Optimum    : yes
  Optimal    : 2
Optimization : 0 1
Calls        : 1
Time         : 0.004s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.005s
Threads      : 3        (Winner: 1) '''
  ];

   List<String> sections = [];
   for (String text in texts) {
  List<String> parts = text.split('Answer:');

  for (int i = 1; i < parts.length; i++) {
    String part = parts[i];
    int endIndex = part.indexOf('Optimization');

    // Check if the word "Optimization" exists
    if (endIndex != -1) {
      // Extract text before "Optimization"
      String section = part.substring(3, endIndex).trim();

      // Check if "OPTIMUM FOUND" exists
      int optimumIndex = section.indexOf('OPTIMUM FOUND');
      if (optimumIndex != -1) {
        // Exclude text starting from "OPTIMUM FOUND" and below
        section = section.substring(0, optimumIndex).trim();
      }
    
     int startIndexTarget = section.indexOf('actualTarget');
   int endIndexTargetAdd = section.indexOf('add', startIndexTarget);
   int endIndexTargetDel = section.indexOf('del', startIndexTarget);

//    if ((startIndexTarget != -1 && endIndexTargetAdd != -1) && (startIndexTarget != -1 && endIndexTargetDel != -1) && (endIndexTargetAdd>endIndexTargetDel)) {
// //if del string is found before add string    
//      section = section.replaceRange(startIndexTarget, endIndexTargetDel, '');
//    }
// //if add string is found before del string
//    else if((startIndexTarget != -1 && endIndexTargetAdd != -1) && (startIndexTarget != -1 && endIndexTargetDel != -1) && (endIndexTargetAdd<endIndexTargetDel)){
//      section = section.replaceRange(startIndexTarget, endIndexTargetAdd, '');
//    }
// //if del string does not exist
//    else if((startIndexTarget != -1 && endIndexTargetAdd != -1) && (startIndexTarget != -1 && endIndexTargetDel == -1)){
//         section = section.replaceRange(startIndexTarget, endIndexTargetAdd, '');
//    }
// //If add string does not exist
//     else if((startIndexTarget != -1 && endIndexTargetDel != -1) && (startIndexTarget != -1 && endIndexTargetAdd == -1)){
//         section = section.replaceRange(startIndexTarget, endIndexTargetDel, '');
//    }
  
       if (section.contains('add')) {
    section =  section.replaceAll('add', 'Add ');
  };
if (section.contains('del')) {
    section =  section.replaceAll('del', 'Delete ');
  };


  // section = section.replaceAll('base_', '');
      
      
      sections.add(section);
    } 
  }
}
  return sections;
  
  }
  

DateTime? convertToSelectedDate(String input) {
        int startIndex =input.lastIndexOf('"');
        int endIndex = input.lastIndexOf('"', startIndex - 1);
    
        if (startIndex != -1 && endIndex != -1 && startIndex != endIndex) {
        String formattedString = input.substring(endIndex + 1, startIndex).replaceAll('_', '-');
        String dateTimeWithoutOffset = formattedString.substring(0, formattedString.indexOf('+'));
        DateTime date = DateTime.parse(dateTimeWithoutOffset);
        return date;
                }
        return null;
  }

   

   
   
  

Widget checkConsistency(String contractId) {
  List<String> filteredAnswers = parseTextIntoAnswers()
      .toSet()
      .where((answer) => answer.contains(contractId))
      .toList();

  // Define sets to hold answers based on criteria
  List<List<String>> answerSets = [];

  // Define criteria for grouping answers
  List<String> criteriaStrings = [
    "contractStatusShape",
    "contractMediumShape",
    "contractCategoryShape",
    "contractContractorShape",
    "removeContractCategory",
    "removeContractStatusShape",
    "effectiveDateShape",
    "endDateShape",
  ];

  Map<String, List<String>> criteriaSets = {};

  for (String answer in filteredAnswers) {
    String criteria = "";
    for (String str in criteriaStrings) {
      if (answer.contains(str)) {
        criteria = str;
        break;
      }
    }

    if (criteria.isEmpty) {
      // Default criteria if none of the predefined strings found
      criteria = "defaultCriteria";
    }

    if (!criteriaSets.containsKey(criteria)) {
      criteriaSets[criteria] = [];
    }
    criteriaSets[criteria]!.add(answer);
  }

  // Convert criteria sets to answer sets
  criteriaSets.forEach((key, value) {
    if (value.isNotEmpty) {
      answerSets.add(value);
    }
  });

  Map<int, int?> selectedAnswers = {}; // Map to store selected answer indices for each set

  return ElevatedButton(
    onPressed: () {
      if (answerSets.isEmpty) {
        // Show modal indicating no inconsistencies found
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('No Inconsistencies Found'),
              content: Text('There are no inconsistencies in your contract data.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'There are inconsistencies in your contract data. Please select the way you want to repair these inconsistencies.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        for (int i = 0; i < answerSets.length; i++)
                          if (answerSets[i].isNotEmpty)
                            ...[
                              SizedBox(height: 20),
                              Text(
                                'Set ${i + 1}:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              for (int j = 0; j < answerSets[i].length; j++)
                                ListTile(
                                  title: Text(answerSets[i][j]),
                                  leading: Radio(
                                    value: j,
                                    groupValue: selectedAnswers[i],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedAnswers[i] = value as int?;
                                      });
                                    },
                                  ),
                                ),
                            ],
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            bool allSetsSelected = true;
                            for (int i = 0; i < answerSets.length; i++) {
                              if (answerSets[i].isNotEmpty && selectedAnswers[i] == null) {
                                allSetsSelected = false;
                                break;
                              }
                            }
                            if (allSetsSelected) {
                              // Perform repair action here with selected answers
                              final contract = await dataProvider.fetchContractById(contractId);
                              for (int i = 0; i < answerSets.length; i++) {
                                if (answerSets[i].isNotEmpty) {
                                  int selectedAnswerIndex = selectedAnswers[i]!;

                                  String answer = answerSets[i][selectedAnswerIndex];
                                  // Status is unknown but it should be Fulfilled, Pending or Violated use case
                                  if (answer.contains("contractStatusShape")) {
                                    if (answer.contains("statusFulfilled")) {
                                      contract.category = "categoryBusinessToConsumer";
                                      log("This is the contract type" + contract.type!);
                                    } else if (answer.contains("statusPending")) {
                                      contract.status = "statusPending";
                                    } else if (answer.contains("statusViolated")) {
                                      contract.status = "statusViolated";
                                    }
                                  }

                                  // Contract category should either be BusinessToBusiness or BusinessToConsumer
                                  if (answer.contains("contractCategoryShape")) {
                                    if (answer.contains("BusinessToBusiness")) {
                                      contract.category = "BusinessToBusiness";
                                    } else if (answer.contains("BusinessToConsumer")) {
                                      contract.category = "BusinessToConsumer";
                                    }
                                  }
                                 //Contract medium should be Written, Transferable, Verbal or Mutual 
                                  if (answer.contains("contractMediumShape")) {
                                    if (answer.contains("writtttenn")) {
                                      contract.medium = "Written";
                                    } else if (answer.contains("transferable")) {
                                      contract.medium = "Transferable";
                                    } else if (answer.contains("verbal")) {
                                      contract.medium = "Verbal";
                                    } else if (answer.contains("mutual")) {
                                      contract.medium = "Mutual";
                                    }
                                  }

                                  //If there are duplicates on the Contract Category the contract should have only one contract category
                                  if(answer.contains("removeContractCategory")){
                                    if(answer.contains("categoryBusinessToBusiness")){
                                      contract.contractors = ["c_370c40d4-4e1a-11ed-9fb9-0242ac150003","c_af45d8e2-5371-11ed-9a79-0242ac150003"];
                                    }
                                    else if(answer.contains("categoryBusinessToConsumer")){
                                          log("categoryBusinessToConsumer");
                                    }
                                  }
                                   
                                  //If there is more than one value on the Contract Status
                                  if(answer.contains("removeContractStatusShape")){
                                    if(answer.contains("statusPending") && answer.contains("statusFulfilled")){
                                      contract.status = "stateViolated";
                                    }

                                    else if(answer.contains("statusPending") && answer.contains("statusViolated")){
                                      contract.status = "hasCreated";
                                    }

                                    else if(answer.contains("statusFulfilled") && answer.contains("statusViolated")){
                                      contract.status = "statePending";
                                    }
                                  }


                           
                                 
                                  if(answer.contains("effectiveDateShape")){
                                  
                                  log(convertToSelectedDate(answer)!.toIso8601String());
                                    //if dates[i] != convertToSelectedDate(answer)!.toIso8601String(){
                                    // contract.effectiveDate = date[i];}
                                  }

                                  if(answer.contains("endDateShape")){

                                    log(convertToSelectedDate(answer)!.toIso8601String());
                                    
                                  }


                                }
                              }
                              Navigator.pop(context);
                              dataProvider.updateContract(contract);
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Selection of the inconsistencies is incomplete.'),
                                    content: Text('Please select an option from each set.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Text('Repair'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      }
    },
    child: Text('Check'),
  );
}




  Widget deleteContractButton(String contractId) {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(Icons.delete, size: 30),
      onPressed: () {
        showConfirmDeletionDialog(contractId);
      },
    );
  }

  showConfirmDeletionDialog(String contractId) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning, size: 40, color: Colors.red),
                Container(height: 20),
                Text(
                    "Are you sure you want to delete the contract: $contractId?"),
              ],
            ),
            actions: [
              MaterialButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                  child: Text('Delete', style: TextStyle(color: Colors.white)),
                  color: Colors.red,
                  onPressed: () async {
                    _dismissDialog();
                    _showDeletingDialog();
                    if (await dataProvider.deleteContractById(contractId)) {
                      _dismissDialog();
                      widget.refresh();
                      showSuccessfulDeletionDialog(contractId);
                    } else {
                      _dismissDialog();
                      showFailedDeletionDialog(contractId);
                    }
                  }),
            ],
          );
        });
  }

  showSuccessfulDeletionDialog(String contractId) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Success!', textAlign: TextAlign.center),
            contentPadding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              Text('The contract $contractId was successfully deleted!',
                  textAlign: TextAlign.center),
              MaterialButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _showDeletingDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Deleting...', textAlign: TextAlign.center),
            contentPadding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
            children: [
              Icon(Icons.schedule, color: Colors.grey, size: 100),
              Text('Your contract is being deleted.',
                  textAlign: TextAlign.center),
              Container(height: 5),
              Center(child: CircularProgressIndicator())
            ],
          );
        });
  }

  showFailedDeletionDialog(String contractId) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Error!'),
            children: [
              Icon(Icons.error, color: Colors.red, size: 60),
              Text('The contract $contractId could not be deleted!'),
              MaterialButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  String _formatContractUri(String contractUri) {
    int length = contractUri.length;
    return contractUri.substring(45, length);
  }

  _dismissDialog() {
    Navigator.pop(context);
  }
}
