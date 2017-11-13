//
//  FreeFoodTableViewController.swift
//  FreeFood
//
//

import UIKit

class FreeFoodTableViewController: UITableViewController,XMLParserDelegate, UISearchBarDelegate {
    var item:[String:String] = [:]
    var items:[[String:String]] = []
    var key = ""
    var currentPage = 1
    
    var servieKey = "J1VE6aO42oZsBXfEw8xhgGYSKt%2BZwu8roQkIzfNRu3doXV3ZVlLzuw2DK%2F7NeHj2ckKKUvA10vr0yUKJS6Yq8g%3D%3D"
    var listEndPoint = "http://opendata.busan.go.kr/openapi/service/ParkingLotInfo/getParkingLotInfoList"
    let detailEndPoint = "http://opendata.busan.go.kr/openapi/service/ParkingLotInfo/getParkingLotInfoDetail"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "공영 주차장"
        
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("data.plist")
        
        if fileManager.fileExists(atPath: (url?.path)!) {
            items = NSArray(contentsOf: url!) as! Array
        } else {
            // 기본 목록 파싱
            getList()
            print("After getList = \(items)")
            
            let tempItems = items  // tableView에서 재활용
            items = []
        
            for mana in tempItems {
                // 상세 목록 파싱
                getDetail(managementNum: mana["managementNum"]!)
            }
            
            print("After getDetail = \(items)")
            
            let temp = items as NSArray  // NSArry는 화일로 저장하기 위함
            temp.write(to: url!, atomically: true)
       }
        tableView.reloadData()
    }
    
    
    @IBAction func actPrev(_ sender: UIBarButtonItem) {
        
        if currentPage != 1 {
            items.removeAll()
            currentPage -= 1
            
            getList()
            let tempItems = items  // tableView에서 재활용
            items = []
            
            for mana in tempItems {
                // 상세 목록 파싱
                getDetail(managementNum: mana["managementNum"]!)
            }

            tableView.reloadData()
        }
    }
    
    @IBAction func actNext(_ sender: UIBarButtonItem) {
        items.removeAll()
        currentPage += 1
        
        getList()
        let tempItems = items  // tableView에서 재활용
        items = []
        
        for mana in tempItems {
            // 상세 목록 파싱
            getDetail(managementNum: mana["managementNum"]!)
        }

        tableView.reloadData()
    }
    

    func getList() {
        let str = listEndPoint + "?serviceKey=\(servieKey)&numOfRows=20&pageNo=\(currentPage)"
        
        if let url = URL(string: str) {
            if let parser = XMLParser(contentsOf: url) {
                parser.delegate = self
                let success = parser.parse()
                if success {
                    print("parse success")
                } else {
                    print("parse fail")
                }
            }
        }
    }
    
    func getDetail(managementNum: String) {
        let str = detailEndPoint + "?serviceKey=\(servieKey)&managementNum=\(managementNum)"
        
        if let url = URL(string: str) {
            if let parser = XMLParser(contentsOf: url) {
                parser.delegate = self
                let success = parser.parse()
                if success {
                    print("parse success")
                } else {
                    print("parse fail")
                }
            }
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        //key = elementName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        key = elementName
        if key == "item" {
            item = [:]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // foundCharacters가 두번 호출
        if item[key] == nil {
            item[key] = string.trimmingCharacters(in: .whitespaces)
            //print("****** \(item[key])")
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            items.append(item)
            print(items)
        }
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "RE", for: indexPath)
        
        let mana = items[indexPath.row]
        cell.textLabel?.text = mana["parkingName"]
        cell.detailTextLabel?.text = mana["addrJibun"]

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        //del이라는 식별자를 찾아서 알맞게 보낸다
        if segue.identifier == "dels"{
            let detailVC = segue.destination as! test
            let selectedPath = tableView.indexPathForSelectedRow
            
            let itme = items[(selectedPath?.row)!]
            
            //테이블에서 선택된 데이터를 찾아 del에 넣어 보낸다
            let title = itme["parkingName"]! as String
            let lat = itme["addrJibun"]! as String
           
            detailVC.tit = title
            detailVC.geos = lat
            
        }
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

       
}
