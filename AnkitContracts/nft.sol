// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _tokenSold;
    Counters.Counter private leafId;
    Counters.Counter private PollId;

    address payable owner;

    uint256 public hello;

    // mapping(uint256 => MarketItem) private idMarketItem;

    mapping(uint256 => LeafItem) public leafMarketItem;

    mapping(uint256 => address) public _creators;

    mapping(uint256 => pollIdInfo) public pollInformation;

    mapping(uint256 => LeafPollInfo) public leafPollCreated;

    mapping(address => mapping(uint256 => VoterInfo)) public voterDetails;

    struct pollIdInfo {
        uint256 PollId;
        uint256 leafId;
        bool pollisActive;
        uint256 price;
        uint256 voteOption;
        uint256 totalVoteCount;
        uint256 totalMembars;
        address[] member;
        bool activeminted;
        bool alreadyminted;
        PollVoteOptions PollVoteOptions;
    }

    struct PollVoteOptions {
        uint256 pollId;
        uint256[] optionsWithVoteCount;
    }

    struct LeafPollInfo {
        uint256 pollId;
        bool pollCreated;
    }

    struct VoterInfo {
        uint256 pollId;
        bool votereligible;
        bool isVote;
        uint256 selectedOption;
    }

    struct LeafItem {
        uint256 _leafId;
        address payable creator;
        string artURL;
        uint256 Parent;
        address contractAddress;
        uint256 Price;
        bool Minted;
    }

    event LeafItemCreated(
        uint256 indexed _leafdId,
        address creator,
        string artURL,
        uint256 Parent,
        address owner,
        uint256 Price,
        bool Minted
    );

    constructor() ERC721("virtual NFT", "VTN") {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can change price");
        _;
    }

    modifier alreadyMinted(uint256 _leafid) {
        require(leafMarketItem[_leafid].Minted == false, "already minted");
        _;
    }

    function createLeafToken(
        uint256 _parent,
        string memory tokenURI,
        uint256 price
    ) public returns (uint256) {
        uint256 Parent;
        leafId.increment();
        uint256 newLeafId = leafId.current();
        if (newLeafId == 1) {
            Parent = 0;
        } else {
            Parent = _parent;
        }
        _creators[newLeafId] = msg.sender;
        // _setLeafURI[newLeafId] = tokenURI;
        createLeafMarketItem(tokenURI, Parent, newLeafId, price);
        return newLeafId;
    }

    function createLeafMarketItem(
        string memory tokenURI,
        uint256 _parent,
        uint256 _leafId,
        uint256 price
    ) private {
        require(price > 0, "price must be greater than 0");

        leafMarketItem[_leafId] = LeafItem(
            _leafId,
            payable(msg.sender),
            tokenURI,
            _parent,
            address(this),
            price,
            false
        );

        emit LeafItemCreated(
            _leafId,
            msg.sender,
            tokenURI,
            _parent,
            address(this),
            price,
            false
        );
    }

    function fetchLeafItem() public view returns (LeafItem[] memory) {
        uint256 itemCount = leafId.current();
        uint256 currentIndex = 0;
        LeafItem[] memory items = new LeafItem[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (leafMarketItem[i + 1].contractAddress == address(this)) {
                uint256 currentId = i + 1;
                LeafItem storage currentItem = leafMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchItemsCreated() public view returns (LeafItem[] memory) {
        uint256 totalCount = leafId.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < totalCount; i++) {
            if (leafMarketItem[i + 1].creator == msg.sender) {
                itemCount += 1;
            }
        }
        LeafItem[] memory items = new LeafItem[](itemCount);
        for (uint256 i = 0; i < totalCount; i++) {
            if (leafMarketItem[i + 1].creator == msg.sender) {
                uint256 currentId = i + 1;
                LeafItem storage currentItem = leafMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchBranchAddresses(uint256 _leafid)
        public
        view
        returns (address[] memory)
    {
        uint256 fixedsize = FixedSize(_leafid);
        uint256 totalCount = _leafid;
        uint256 currentindex = fixedsize - 1;

        address[] memory items = new address[](fixedsize);
        while (totalCount > 0) {
            address add = leafMarketItem[totalCount].creator;
            items[currentindex] = add;
            totalCount = leafMarketItem[totalCount].Parent;
            if (currentindex > 0) {
                currentindex--;
            }
        }
        return items;
    }

    function FixedSize(uint256 _leafid) private view returns (uint256) {
        uint256 _totalCount = _leafid;
        uint256 fixedsize = 0;
        while (_totalCount > 0) {
            _totalCount = leafMarketItem[_totalCount].Parent;
            fixedsize++;
        }
        return fixedsize;
    }

    // create NFT Poll function

    function createPoll(uint256 _leafid, uint256 _price)
        public
        returns (uint256)
    {
        require(
            !leafPollCreated[_leafid].pollCreated,
            "Poll already Created for this LeafId"
        );
        require(
            leafMarketItem[_leafid].creator == msg.sender,
            "You are not creator of this leaf"
        );
        PollId.increment();
        uint256 newPollId = PollId.current();
        address[] memory _members = fetchBranchAddresses(_leafid);
        uint256 _totalMembars = _members.length;
        uint256 _voteOptins = 2;
        uint256[] memory _optionsWithVoteCount = new uint256[](_voteOptins);

        pollInformation[newPollId] = pollIdInfo(
            newPollId,
            _leafid,
            true,
            _price,
            _voteOptins,
            0,
            _totalMembars,
            _members,
            false,
            false,
            PollVoteOptions(newPollId, _optionsWithVoteCount)
        );

        leafPollCreated[_leafid] = LeafPollInfo(newPollId, true);

        for (uint256 i = 0; i < _totalMembars; i++) {
            voterDetails[_members[i]][newPollId] = VoterInfo(
                newPollId,
                true,
                false,
                0
            );
        }

        return newPollId;
    }

    //start voting for create NFT

    function createVoting(
        uint256 _pollid,
        uint256 _voteid,
        uint256 _leafdId
    ) public returns (bool) {
        VoterInfo storage voter = voterDetails[msg.sender][_pollid];
        pollIdInfo storage poll = pollInformation[_pollid];
        require(voter.votereligible == true, "You are not Eligible for Vote"); // check Voter is Eligible for Vote
        require(voter.isVote == false, "You are voted already"); // check Voter is already Voted
        require(poll.pollisActive == true, "Poll is not active"); // Check Poll is already active or not
        poll.PollVoteOptions.optionsWithVoteCount[_voteid] += 1;
        voter.isVote = true;
        poll.totalVoteCount += 1;
        voter.selectedOption = _voteid;
        address[] memory _members = poll.member;
        uint256 greaterValue = (poll.PollVoteOptions.optionsWithVoteCount[1] *
            100) / poll.totalMembars;
        uint256 lessValue = (poll.PollVoteOptions.optionsWithVoteCount[0] *
            100) / poll.totalMembars;

        if (_members.length == 2) {
            if (
                _members[0] == msg.sender &&
                voterDetails[_members[0]][_pollid].selectedOption == 1
            ) {
                poll.activeminted = true;
                poll.pollisActive = false;
                leafPollCreated[_leafdId].pollCreated = false;
                return true;
            } else if (
                _members[0] == msg.sender &&
                voterDetails[_members[0]][_pollid].selectedOption == 0
            ) {
                poll.activeminted = false;
                poll.pollisActive = false;
                leafPollCreated[_leafdId].pollCreated = false;
                return true;
            }
            return true;
        }

        if (_members.length > 2) {
            if (
                voterDetails[_members[0]][_pollid].selectedOption == 1 &&
                voterDetails[_members[1]][_pollid].selectedOption == 1 &&
                voterDetails[_members[2]][_pollid].selectedOption == 1
            ) {
                hello = 10;
                poll.activeminted = true;
                poll.pollisActive = false;
                leafPollCreated[_leafdId].pollCreated = false;
                return true;
            }
        }

        if (greaterValue >= 51) {
            poll.activeminted = true;
            poll.pollisActive = false;
            leafPollCreated[_leafdId].pollCreated = false;
            return true;
        }

        if (lessValue >= 51) {
            poll.activeminted = false;
            poll.pollisActive = false;
            leafPollCreated[_leafdId].pollCreated = false;
            return true;
        }
    }

    // create NFT Token function

    function createToken(uint256 _pollid, uint256 _leafId)
        public
        payable
        returns (uint256)
    {
        require(
            pollInformation[_pollid].activeminted == true,
            "You are not active for Minted"
        );
        require(
            pollInformation[_pollid].alreadyminted == false,
            "You are already Minted this poll id leaf"
        );
        require(
            leafMarketItem[_leafId].Minted == false,
            "You are already Minted this leafid"
        );
        require(
            leafMarketItem[_leafId].creator == msg.sender,
            "You are not creator of this leaf"
        );
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, leafMarketItem[_leafId].artURL);
        pollInformation[_pollid].alreadyminted == true;
        leafMarketItem[_leafId].Minted == true;
        return newTokenId;
    }
}