// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.28; // Tận dụng Custom Errors và tính năng mới nhất

// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// //0xa553639E9f9E47181D21DC6408f4422386F8a187
// contract MarketMedia is ReentrancyGuard, ERC721 {
//     uint256 private _tokenIdCounter;

//     address payable public owner;

//     enum SaleType { 
//         NOT_LISTED,   
//         FIXED_PRICE,   
//         AUCTION      
//     }

//     error OnlyOwnerRequest();
//     error NotOwnerToken();
//     error TitleRequired();
//     error ImageRequired();
//     error PriceMustBePositive();
//     error AlreadyListed();
//     error NotListedForFixedPrice();
//     error ExactPriceRequired();
//     error CannotBuyOwnToken();
//     error ETHTransferFailed();
//     error AuctionEnded();
//     error BidTooLow();
//     error AuctionNotEnded();
//     error NotListedForAuction();
//     error NoFundsAvailable();
//     error FeeWithdrawalFailed();
//     error TokenDoesNotExist();
//     error InvalidAddress();
//     error PageStartFromOne();
//     error LimitMustBePositive();
//     error DurationTooShort();
//     error NotApproved();

//     struct AuctionDetails {
//         address payable highestBidder;
//         uint256 currentPrice;
//         uint256 endTime;
//     }

//     struct TokenDetails {
//         string title;
//         string image;
//         uint256 price; 
//         SaleType saleType;
//     }

//     struct TokenView {
//         uint256 id;
//         string title;
//         string image;
//         uint256 price;
//         SaleType saleType;
//         address owner;
//         bool listed;
//         uint256 priceForSale;
//         AuctionDetails auctionDetails;
//     }

//     // Mappings:
//     mapping(uint256 => TokenDetails) public tokens;
//     mapping(address => mapping(uint256 => uint256)) addressTokens;
//     mapping(address => mapping(uint256 => uint256)) addressIds;
//     mapping(uint256 => uint256) public salePrices;
//     mapping(uint256 => AuctionDetails) public auctionTokens;
//     mapping(address => uint256) public pendingReturns; 

//     // Fee and constants
//     uint256 public constant FEE_PERCENTAGE = 250; // 2.5% (250 / 10000)
//     uint256 public immutable MIN_AUCTION_DURATION = 1 days;
//     uint256 private _pendingFees; 

//     // Events
//     event Received(address sender, uint256 amount);
//     event MintNFT(address indexed minter, uint256 tokenId);
//     event ListForSale(uint256 tokenId, uint256 price);
//     event ListForAuction(uint256 tokenId, uint256 startPrice, uint256 duration);
//     event BuySuccessfullToken(address indexed buyer, uint256 tokenId, uint256 price);
//     event BidNewPrice(address indexed bidder, uint256 tokenId, uint256 price);
//     event Settlement(address indexed caller, uint256 tokenId);
//     event RefundPending(address indexed caller, uint256 amount);
//     event CancelSale(uint256 indexed tokenId);
//     event CancelAuction(uint256 indexed tokenId);
//     event WithdrawFees(address indexed owner, uint256 amount);

//     // Modifiers
//     modifier onlyOwner() {
//         if (owner != msg.sender) {
//             revert OnlyOwnerRequest();
//         }
//         _;
//     }

//     modifier OnlyOwnerToken(uint256 tokenId) {
//         if (ownerOf(tokenId) != msg.sender) {
//             revert NotOwnerToken();
//         }
//         _;
//     }

//     constructor() ERC721("Market NFT", "MKT") {
//         owner = payable(msg.sender);
//     }
    

//     function updateAddressTokens_Direct(address from, address to, uint256 tokenId) internal {
//         if (from != address(0)) {
//             uint256 newBalanceFrom = balanceOf(from);
            
//             uint256 lastTokenIndex = newBalanceFrom; 
            
//             uint256 indexToRemove = addressIds[from][tokenId];

//             if (indexToRemove != lastTokenIndex) {
//                 uint256 lastTokenId = addressTokens[from][lastTokenIndex];
                
//                 addressTokens[from][indexToRemove] = lastTokenId;
//                 addressIds[from][lastTokenId] = indexToRemove;
//             }
            
//             delete addressIds[from][tokenId];
//             delete addressTokens[from][lastTokenIndex]; 
//         }

//         if (to != address(0)) {
//             uint256 newIndex = balanceOf(to) - 1; 
            
//             addressTokens[to][newIndex] = tokenId;
//             addressIds[to][tokenId] = newIndex;
//         }
//     }
    

//     function mintNewNFT(string memory title, string memory image) external {
//         if (bytes(title).length == 0) revert TitleRequired();
//         if (bytes(image).length == 0) revert ImageRequired();

//         _tokenIdCounter++;
//         uint256 newTokenId = _tokenIdCounter;

//         _safeMint(msg.sender, newTokenId); 
        
//         updateAddressTokens_Direct(address(0), msg.sender, newTokenId);
        
//         tokens[newTokenId] = TokenDetails({
//             title: title,
//             image: image,
//             price: 0,
//             saleType: SaleType.NOT_LISTED
//         });
        
//         emit MintNFT(msg.sender, newTokenId);
//     }

//     function saleNFT(uint256 tokenId, uint256 price) external OnlyOwnerToken(tokenId) nonReentrant {
//         TokenDetails storage token = tokens[tokenId];
//         if (price == 0) revert PriceMustBePositive();
//         if (token.saleType != SaleType.NOT_LISTED) revert AlreadyListed();
        

//         token.saleType = SaleType.FIXED_PRICE;
//         salePrices[tokenId] = price;

//         emit ListForSale(tokenId, price);
//     }

//     function buyNFT(uint256 tokenId) external payable nonReentrant {
//         TokenDetails storage token = tokens[tokenId];
//         if (token.saleType != SaleType.FIXED_PRICE) revert NotListedForFixedPrice();
        
//         uint256 listingPrice = salePrices[tokenId];
//         if (msg.value != listingPrice) revert ExactPriceRequired(); 

//         address seller = ownerOf(tokenId);
//         if (seller == msg.sender) revert CannotBuyOwnToken();

//         token.saleType = SaleType.NOT_LISTED;
//         token.price = listingPrice;
//         delete salePrices[tokenId];

//         _safeTransfer(seller, msg.sender, tokenId, "");
        
//         updateAddressTokens_Direct(seller, msg.sender, tokenId);

//         uint256 fee = (msg.value * FEE_PERCENTAGE) / 10000;
//         uint256 sellerAmount = msg.value - fee;
//         _pendingFees += fee;
//         pendingReturns[seller] += sellerAmount; 

//         emit BuySuccessfullToken(msg.sender, tokenId, msg.value);
//     }
    
//     function cancelSale(uint256 tokenId) external OnlyOwnerToken(tokenId) {
//         TokenDetails storage token = tokens[tokenId];
//         if (token.saleType != SaleType.FIXED_PRICE) revert NotListedForFixedPrice();
//         token.saleType = SaleType.NOT_LISTED;
//         delete salePrices[tokenId];
//         emit CancelSale(tokenId);
//     }


//     function auctionNFT(uint256 tokenId, uint256 startPrice, uint256 duration) external OnlyOwnerToken(tokenId) nonReentrant {
//         if (duration < MIN_AUCTION_DURATION) revert DurationTooShort();
//         if (startPrice == 0) revert PriceMustBePositive();
//         TokenDetails storage token = tokens[tokenId];
//         if (token.saleType != SaleType.NOT_LISTED) revert AlreadyListed();
        

//         token.saleType = SaleType.AUCTION;
//         auctionTokens[tokenId] = AuctionDetails({
//             highestBidder: payable(address(0)),
//             currentPrice: startPrice,
//             endTime: block.timestamp + duration
//         });

//         emit ListForAuction(tokenId, startPrice, duration);
//     }

//     /// @notice Places a bid on an auction.
//     function bid(uint256 tokenId) external payable nonReentrant {
//         TokenDetails storage token = tokens[tokenId];
//         if (token.saleType != SaleType.AUCTION) revert NotListedForAuction();
//         AuctionDetails storage auction = auctionTokens[tokenId];
//         if (block.timestamp >= auction.endTime) revert AuctionEnded();

//         if (msg.value <= auction.currentPrice) revert BidTooLow();
//         if (auction.highestBidder != address(0) && auction.highestBidder != ownerOf(tokenId)) {
//             pendingReturns[auction.highestBidder] += auction.currentPrice;
//         }

//         auction.currentPrice = msg.value;
//         auction.highestBidder = payable(msg.sender);

//         emit BidNewPrice(msg.sender, tokenId, msg.value);
//     }

//     function auctionSettlement(uint256 tokenId) external nonReentrant {
//         TokenDetails storage token = tokens[tokenId];
//         if (token.saleType != SaleType.AUCTION) revert NotListedForAuction();
//         AuctionDetails storage auction = auctionTokens[tokenId];
//         if (block.timestamp < auction.endTime) revert AuctionNotEnded();

//         address seller = ownerOf(tokenId);
//         address highestBidder = auction.highestBidder;

//         token.saleType = SaleType.NOT_LISTED;
//         token.price = auction.currentPrice;
//         delete auctionTokens[tokenId];

//         if (highestBidder != address(0)) {

//             _safeTransfer(seller, highestBidder, tokenId, ""); 
            
//             updateAddressTokens_Direct(seller, highestBidder, tokenId);
            
//             uint256 fee = (auction.currentPrice * FEE_PERCENTAGE) / 10000;
//             uint256 sellerAmount = auction.currentPrice - fee;
//             _pendingFees += fee;
//             pendingReturns[seller] += sellerAmount; 
//         }
        
//         emit Settlement(msg.sender, tokenId);
//     }

//     function cancelAuction(uint256 tokenId) external OnlyOwnerToken(tokenId) {
//         TokenDetails storage token = tokens[tokenId];
//         if (token.saleType != SaleType.AUCTION) revert NotListedForAuction();
//         if (auctionTokens[tokenId].endTime <= block.timestamp) revert AuctionEnded();
        
//         token.saleType = SaleType.NOT_LISTED;

//         if (auctionTokens[tokenId].highestBidder != address(0) && auctionTokens[tokenId].highestBidder != ownerOf(tokenId)) {
//             pendingReturns[auctionTokens[tokenId].highestBidder] += auctionTokens[tokenId].currentPrice;
//         }

//         delete auctionTokens[tokenId];
//         emit CancelAuction(tokenId);
//     }
    

//     function withdrawPendingReturns() external nonReentrant {
//         uint256 amount = pendingReturns[msg.sender];
//         if (amount == 0) revert NoFundsAvailable();
//         pendingReturns[msg.sender] = 0;
        
//         (bool success, ) = payable(msg.sender).call{value: amount}("");
//         if (!success) revert ETHTransferFailed();
//         emit RefundPending(msg.sender, amount);
//     }

//     function withdrawFees() external onlyOwner nonReentrant {
//         uint256 amount = _pendingFees;
//         if (amount == 0) revert NoFundsAvailable();
//         _pendingFees = 0;
        
//         (bool success, ) = payable(owner).call{value: amount}("");
//         if (!success) revert FeeWithdrawalFailed();
//         emit WithdrawFees(owner, amount);
//     }

//     function getPendingFees() external view returns(uint256) {
//         return _pendingFees;
//     }

//     function getTokenDetail(uint256 tokenId)
//         public
//         view
//         returns (TokenView memory)
//     {
//         if (_tokenIdCounter == 0 || tokenId == 0 || bytes(tokens[tokenId].title).length == 0) revert TokenDoesNotExist();

//         TokenDetails storage t = tokens[tokenId];

//         TokenView memory viewData = TokenView({
//             id: tokenId,
//             title: t.title,
//             image: t.image,
//             price: t.price,
//             saleType: t.saleType,
//             owner: ownerOf(tokenId),
//             listed: t.saleType != SaleType.NOT_LISTED,
//             priceForSale: 0,
//             auctionDetails: AuctionDetails({
//                 highestBidder: payable(address(0)),
//                 currentPrice: 0,
//                 endTime: 0
//             })
//         });

//         if (t.saleType == SaleType.AUCTION) {
//             viewData.auctionDetails = auctionTokens[tokenId];
//         }

//         if (t.saleType == SaleType.FIXED_PRICE) {
//             viewData.priceForSale = salePrices[tokenId];
//         }

//         return viewData;
//     }

//     function getTokenPage(uint256 pageNumber, uint8 limit)
//         public
//         view
//         returns (TokenView[] memory)
//     {
//         if (pageNumber == 0) revert PageStartFromOne();
//         if (limit == 0) revert LimitMustBePositive();

//         uint256 total = _tokenIdCounter;
//         uint256 start = (pageNumber - 1) * limit;

//         if (start >= total) {
//             return new TokenView[](0);
//         }

//         uint256 end = start + limit;
//         if (end > total) end = total;

//         uint256 size = end - start;
//         TokenView[] memory result = new TokenView[](size);

//         for (uint256 i = 0; i < size; i++) {
//             uint256 tokenId = start + i + 1;
//             result[i] = getTokenDetail(tokenId);
//         }

//         return result;
//     }

//     function getMyTokens()
//         external
//         view
//         returns (TokenView[] memory)
//     {
//         uint256 length = balanceOf(msg.sender);

//         TokenView[] memory result = new TokenView[](length);

//         for (uint256 i = 0; i < length; i++) {
//             result[i] = getTokenDetail(addressTokens[msg.sender][i]);
//         }

//         return result;
//     }


//     function getTokensByAddress(address _address)
//         external
//         view
//         returns (TokenView[] memory)
//     {
//         if (_address == address(0)) revert InvalidAddress();

//         uint256 length = balanceOf(_address);

//         TokenView[] memory result = new TokenView[](length);

//         for (uint256 i = 0; i < length; i++) {
//             result[i] = getTokenDetail(addressTokens[_address][i]); 
//         }

//         return result;
//     }
    
//     receive() external payable {
//         emit Received(msg.sender, msg.value);
//     }

//     fallback() external payable {}
// }