//
//  MyFriendsViewController.swift
//  vk
//
//  Created by Rafael Khanov on 26.10.2019.
//  Copyright © 2019 Rafael Khanov. All rights reserved.
//

import UIKit
import AlamofireImage

class MyFriendsViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    var friends = [Friends]()
    var sortedFriendsDict = [Character: [Friends]]()
    var sortFriendsArray = [Friends]()
    var filteredSerch = [Friends]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "FriendXibCell", bundle: nil), forCellReuseIdentifier: "FriendXibCell")
        
        // MARK: - Request getAllFriends
        let NS = NetworkService()
        let requestMethod = "friends.get"
        let parametersName = "fields"
        let parametersDescription = "nickname, photo_50"

        NS.getRequest(
            method: requestMethod,
            parametersName: parametersName,
            parametersDescription: parametersDescription,
            parse:  { data in
                try! JSONDecoder().decode(
                    FriendsResponse.self,
                    from: data
                )
            },
            completion: { [weak self] friends in
           
            guard let this = self else { return }
            this.friends = friends.response.items
                this.sortedFriendsDict = this.sortFriends(friends: friends.response.items)
            this.tableView.reloadData()
        })
    }

    // MARK-- sorted friend list
    
    private func sortFriends(friends: [Friends]) -> [Character: [Friends]] {
        var friendDict = [Character: [Friends]]()
        
        friends.forEach{ friend in
            guard let firstChar = friend.lastName.first else { return }
            
            if var newArray = friendDict[firstChar] {
                newArray.append(friend)
                friendDict[firstChar] = newArray.sorted{$0.lastName > $1.lastName}
            } else {
                friendDict[firstChar] = [friend]
            }
        }
        return friendDict
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {

        return sortedFriendsDict.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let keySorted = sortedFriendsDict.keys.sorted()
        return String(keySorted[section])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let keySorted = sortedFriendsDict.keys.sorted()
        return sortedFriendsDict[keySorted[section]]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: "FriendXibCell", for:
                    indexPath) as? FriendXibCell
                else {
                    preconditionFailure("FriendXibCell ")
            }
            
            let firstChar = sortedFriendsDict.keys.sorted()[indexPath.section]
            let friends = sortedFriendsDict[firstChar]!
            let friend = friends[indexPath.row]
            
            cell.myFriendLabel.text = friend.firstName + " " + friend.lastName
            let url = URL(string: friend.photo)!
            cell.myFriendImageView.af.setImage(withURL: url)
           
            return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let charityEventsVC = UIStoryboard(
            name: "Main",
            bundle: nil
        ).instantiateViewController(
            withIdentifier: "FriendsPhotos"
            ) as! FriendsPhotosCollectionViewController
        
        let keySection = sortedFriendsDict.keys.sorted()[indexPath.section]
        let detailInfo = sortedFriendsDict[keySection]![indexPath.row]
        
        charityEventsVC.userID = detailInfo.userId
        charityEventsVC.title = detailInfo.firstName
    
        navigationController?.pushViewController(charityEventsVC, animated: true)
    }
}

extension MyFriendsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.placeholder = " Search..."
        if searchText.isEmpty {
            filteredSerch = friends
        } else {
            filteredSerch = friends.filter{ $0.lastName.contains(searchText.lowercased())}
        }
        sortedFriendsDict = sortFriends(friends: filteredSerch)
        self.tableView.reloadData()
    }
}


