# Solomon NFT Lending Protocol (SNL): Phân tích Kỹ thuật và Nghiệp vụ

Dự án **Solomon NFT Lending Protocol (SNL)** là một nền tảng cho vay phi tập trung được xây dựng trên Solidity, tập trung vào việc sử dụng các tài sản ERC20 được token hóa thành NFT (SCNFT) làm thế chấp. Dưới đây là phân tích chi tiết về kiến trúc, các công thức tài chính cốt lõi và hướng dẫn triển khai.

---

## 1. Kiến trúc Hợp đồng (Contract Architecture)

Hệ thống bao gồm ba thành phần tương tác chính, tạo thành một hệ sinh thái cho vay khép kín:

### 1.1. `CycloneERC20Token` (Tài sản Vay và Cơ sở)

* **Vai trò:** Đóng vai trò là tài sản có thể thay thế (fungible) được sử dụng để cung cấp thanh khoản cho Pool, đồng thời là tài sản được người dùng gửi vào để mint NFT thế chấp.
* **Điểm chính:** Cung cấp các chức năng tiêu chuẩn của ERC20, cùng với cơ chế mint token khởi tạo và token miễn phí theo quy tắc `onlyNewUser`.

### 1.2. `CycloneERC721Token` (SCNFT - Tài sản Thế chấp)

* **Vai trò:** Hợp đồng ERC721 này đóng gói một lượng cố định của `CycloneERC20Token` thành một NFT duy nhất. NFT này là đơn vị được sử dụng để thế chấp.
* **Cơ chế Bảo mật Thế chấp:**
    * **Khóa:** Sử dụng mapping `collateralApprover` để theo dõi Pool nào đang nắm giữ quyền thanh lý NFT.
    * Các hàm `approve`, `transferFrom` và `withdrawCollateral` được ghi đè để **ngăn chặn** mọi hoạt động thay đổi quyền sở hữu hoặc rút tài sản cơ sở nếu NFT đang được thế chấp (`collateralApprover != address(0)`). Điều này đảm bảo tính toàn vẹn của tài sản thế chấp.

### 1.3. `SolomonTreasury` (Lõi Giao thức)

* **Vai trò:** Là trung tâm xử lý logic tài chính, quản lý thanh khoản, lãi suất, và rủi ro.

---

## 2. Logic Tài chính và Công thức Cốt lõi

Giao thức sử dụng mô hình lãi suất phức tạp và cơ chế chỉ số (Index) để đảm bảo tính toán chính xác khoản nợ và lãi suất.

### 2.1. Tính toán Tích lũy Lãi suất và Nợ (Accrual & Debt Calculation)

Lãi suất được tích lũy theo thời gian bằng cách tăng dần **Chỉ số Vay** (`borrowIndex`).

**a. Cập nhật Chỉ số Vay (`borrowIndex`):**
$$\text{New Borrow Index} = \text{Old Borrow Index} + \frac{(\text{Old Borrow Index} \times \text{Borrow Rate} \times \Delta t)}{\text{SECONDS PER YEAR} \times \text{ONE}}$$
* Trong đó $\Delta t$ là thời gian trôi qua (`timeElapsed`).

**b. Tính Tổng Nợ Hiện tại (`getDebtForUser`):**
Khoản nợ hiện tại được tính bằng cách nhân Vốn gốc (`principal`) với tỷ lệ tăng của Chỉ số Vay kể từ lần cuối cùng khoản vay được cập nhật:
$$\text{Total Debt} = \text{Principal} \times \left( \frac{\text{Current Borrow Index}}{\text{Index At Borrow}} \right)$$

**c. Tỷ lệ Dự trữ (Reserves):**
Một phần lãi suất tích lũy (`Gross Interest`) được chuyển vào `totalReserves` theo `reserveFactor` để bảo vệ hợp đồng khỏi các khoản lỗ bất ngờ hoặc được sử dụng cho các mục đích quản trị.
$$\text{Reserve Amount} = \text{Gross Interest} \times \text{Reserve Factor}$$

### 2.2. Mô hình Lãi suất Thuật toán (Kink Model)

Tỷ lệ Vay (`borrowRate`) được xác định bởi Tỷ lệ Sử dụng ($U$), sử dụng hai độ dốc (`slope1` và `slope2`) để điều chỉnh hành vi của người dùng.

**a. Tỷ lệ Sử dụng ($U$):**
$$U = \frac{\text{Total Borrowed}}{\text{Total Deposited}}$$

**b. Tính Lãi suất Vay ($R_B$)** :

* **Khi $U < U_{kink}$:** Lãi suất tăng tuyến tính với độ dốc thấp ($slope_1$).
    $$R_B = R_0 + U \times \left( \frac{R_{kink} - R_0}{U_{kink}} \right)$$
* **Khi $U \ge U_{kink}$:** Lãi suất tăng tuyến tính với độ dốc cao ($slope_2$).
    $$R_B = R_{kink} + (U - U_{kink}) \times \left( \frac{R_{max} - R_{kink}}{1 - U_{kink}} \right)$$

### 2.3. Cơ chế Thanh lý (Liquidation Logic)

Cơ chế này sử dụng Oracle (giả định bằng `getPriceInUSD`) để so sánh giá trị nợ và giá trị thế chấp.

**Điều kiện Thanh lý (`checkLiquidationStatus`):**
Khoản vay được coi là đủ điều kiện thanh lý khi:
$$\text{Debt Value}_{USD} \times 10000 \ge \text{Collateral Value}_{USD} \times \text{LIQUIDATION THRESHOLD}$$

* $10000$: Thang đo (Scale) $100\%$.
* $\text{LIQUIDATION THRESHOLD}$: Ngưỡng được thiết lập (ví dụ: $8000$ cho $80\%$).

---


## 🚀 Hướng dẫn Triển khai Chi tiết

Tôi sẽ giả định bạn đang sử dụng thang đo (scale) $10^{18}$ (`ONE`) cho các giá trị tiền tệ và tỷ lệ (tức là $1$ đơn vị token hoặc $100\%$ tương đương $1000000000000000000$).

### 1. Triển khai `CycloneERC20Token`

Đây là token ERC20 sẽ được dùng làm tài sản vay và tài sản cơ sở cho NFT.

* **Hợp đồng:** `CycloneERC20Token`
* **Tham số Constructor:**

| Tham số | Ý nghĩa | Ví dụ (Giá trị $10^{18}$ unit) |
| :--- | :--- | :--- |
| `initialSupply` | Tổng cung ban đầu. | `1000000000000000000000000` (1 triệu token) |
| `_FREE_TOKEN_AMOUNT`| Số token miễn phí cho người dùng mới. | `1000000000000000000000` (1000 token) |

* **Kết quả:** Ghi lại **Địa chỉ ERC20** (Ví dụ: `0x...ERC20_Address`).

---

### 2. Triển khai `CycloneERC721Token`

Hợp đồng NFT này sẽ đóng gói token ERC20 ở Bước 1.

* **Hợp đồng:** `CycloneERC721Token`
* **Tham số Constructor:**

| Tham số | Ý nghĩa | Giá trị Mẫu |
| :--- | :--- | :--- |
| `_token` | Địa chỉ token ERC20 (tài sản cơ sở NFT). | **Địa chỉ ERC20** (từ Bước 1) |

* **Kết quả:** Ghi lại **Địa chỉ SCNFT** (Ví dụ: `0x...SCNFT_Address`).

---

### 3. Triển khai `SolomonTreasury`

Đây là hợp đồng cốt lõi, nơi logic tài chính được thiết lập.

* **Hợp đồng:** `SolomonTreasury`
* **Tham số Constructor:**

| Tham số | Ý nghĩa | Ví dụ (Scale $10^{18}$) | Giải thích |
| :--- | :--- | :--- | :--- |
| `_token` | **Token ERC20** (tài sản vay). | `ERC20_Address` | Địa chỉ từ Bước 1. |
| `_scNFT` | **Token ERC721** (tài sản thế chấp). | `SCNFT_Address` | Địa chỉ từ Bước 2. |
| `_baseRate` | $R_0$: Lãi suất cơ bản ($1\%$). | `10000000000000000` | $0.01 \times 10^{18}$ |
| `_kinkRate` | $R_{kink}$: Lãi suất tại điểm gãy ($5\%$). | `50000000000000000` | $0.05 \times 10^{18}$ |
| `_maxRate` | $R_{max}$: Lãi suất tối đa ($20\%$). | `200000000000000000` | $0.2 \times 10^{18}$ |
| `_kinkUtilization`| $U_{kink}$: Tỷ lệ sử dụng tối ưu ($80\%$).| `800000000000000000` | $0.8 \times 10^{18}$ |
| `_reserveFactor`| Tỷ lệ dự trữ ($10\%$). | `100000000000000000` | $0.1 \times 10^{18}$ |



* **Kết quả:** Ghi lại **Địa chỉ Treasury** (Ví dụ: `0x...Treasury_Address`).


### Code
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

contract CycloneERC20Token is ERC20, Ownable {

    mapping(address => bool) isEarnFreeToken;
    uint256 public immutable FREE_TOKEN_AMOUNT;

    modifier onlyNewUser() {
        require(_msgSender() != address(0) && !isEarnFreeToken[_msgSender()],"You already earn free token!");
        _;
    }

    event Mint(address indexed from, address indexed to, uint256 amount);

    constructor(uint256 initialSupply, uint256 _FREE_TOKEN_AMOUNT) ERC20("CycloneToken","CLT") Ownable(_msgSender()) {
        FREE_TOKEN_AMOUNT = _FREE_TOKEN_AMOUNT;
        _mint(_msgSender(),initialSupply);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to,amount);
        emit Mint(owner(), to, amount);
    }
    
    function earnFreeToken() external onlyNewUser {
        _mint(_msgSender(),FREE_TOKEN_AMOUNT);
    }
}

contract CycloneERC721Token is ERC721, Ownable {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;

    Counters.Counter private _tokenIdCounter;
    IERC20 public immutable cycloneERC20Token;
    mapping(uint256 => uint256) public depositValue;
    
    // MAPPING MỚI: Theo dõi NFT nào đang được thế chấp
    // tokenId => địa chỉ Lending Pool đang nắm quyền thế chấp (address(0) nếu không thế chấp)
    mapping(uint256 => address) public collateralApprover;

    // EVENTS
    event CollateralMinted(address indexed owner, uint256 tokenId, uint256 value);
    event CollateralWithdrawn(address indexed owner, uint256 tokenId, uint256 value);
    event CollateralApproved(uint256 tokenId, address indexed approvedPool);
    event CollateralLockApproved(uint256 tokenId, address indexed locker);
    event CollateralUnLockApproved(uint256 tokenId, address indexed unlocker);

    error OwnerCantWithdrawTokenCollateralized(uint256 tokenId);

    constructor(address _token) 
        ERC721("SolomonCollateral", "SCNFT") 
        Ownable(msg.sender)
    {
        cycloneERC20Token = IERC20(_token);
    }
    
    // --- CHỨC NĂNG NGƯỜI DÙNG: GỬI TIỀN / MINT NFT (Giữ nguyên) ---
    function mintCollateral(uint256 amount) external returns (uint256) {
        require(amount > 0, "Amount must be greater than zero");

        cycloneERC20Token.safeTransferFrom(msg.sender, address(this), amount);
        _tokenIdCounter.increment();

        uint256 newId = _tokenIdCounter.current();
        depositValue[newId] = amount;

        _safeMint(msg.sender, newId); 
        emit CollateralMinted(msg.sender, newId, amount);

        return newId;
    }

    // --- OVERRIDE APPROVE VÀ SET APPROVAL FOR ALL ---

    /**
     * @notice Chỉ cho phép cấp phép (approve) nếu NFT không đang được thế chấp.
     * @dev Ghi lại Pool được cấp phép vào `collateralApprover` nếu đó là Pool cho vay.
     */
    function approve(address to, uint256 tokenId) public override {
        require(collateralApprover[tokenId] == address(0), "Cannot change approval while NFT is collateralized");
        super.approve(to, tokenId);
    }

    function approveForCollateral(address to, uint256 tokenId) external {
        require(collateralApprover[tokenId] == address(0), "Cannot change approval while NFT is collateralized");
        require(_isApprovedOrOwner(msg.sender, tokenId), "SCNFT: Caller not authorized");
        super.approve(to, tokenId);
        collateralApprover[tokenId] = to;
        emit CollateralApproved(tokenId, to);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(collateralApprover[tokenId] == address(0), "Cannot transferFrom while NFT is collateralized");
        super.transferFrom(from,to,tokenId);
    }
    //

    function lockActivitiesForOwnerTokenCollateral(uint256 tokenId) external {
        require(getApproved(tokenId) == msg.sender, "Only approve collate can execution");
        require(collateralApprover[tokenId] == address(0), "Cannot lock NFT is collateralized");
        collateralApprover[tokenId] = msg.sender;
        emit CollateralLockApproved(tokenId,msg.sender);
    }


    function unLockActivitiesForOwnerTokenCollateral(uint256 tokenId) external {
        address collater = collateralApprover[tokenId];
        require(collater != address(0), "Token id not validate");
        require(msg.sender == collater, "Caller cant not unlock, require address has been approved");

        delete collateralApprover[tokenId];
        emit CollateralUnLockApproved(tokenId, msg.sender);
    }
    
    // --- CHỨC NĂNG NGƯỜI DÙNG: RÚT TIỀN / BURN NFT ---


    function withdrawCollateral(uint256 tokenId) external {
        address approvedForCollateral = collateralApprover[tokenId];
        
        require(_isApprovedOrOwner(msg.sender, tokenId), "SCNFT: Caller not authorized to withdraw");

        if (approvedForCollateral != address(0)) {
            require(msg.sender != approvedForCollateral, "SCNFT: NFT is approved for lending, cannot withdraw");
        }
        
        uint256 value = depositValue[tokenId];
        require(value > 0, "SCNFT: Token ID not found or value is zero");

        // 1. Burn NFT
        _burn(tokenId);
        
        // 2. Xóa dữ liệu
        delete depositValue[tokenId];
        delete collateralApprover[tokenId]; // Xóa trạng thái thế chấp

        // 3. Trả lại tài sản cơ sở
        cycloneERC20Token.safeTransfer(msg.sender, value);

        emit CollateralWithdrawn(msg.sender, tokenId, value);
    }
    
    // --- HÀM VIEW (Giữ nguyên) ---
    function getTokenValue(uint256 tokenId) public view returns (uint256) {
        return depositValue[tokenId];
    }

    function getApprovedCollateral(uint256 tokenId) external view returns(address) {
        return collateralApprover[tokenId];
    } 

    // INTERNAL FUNCTION 
    function _isApprovedOrOwner(address user, uint256 tokenId) internal view returns(bool) {
        bool isOwner = ownerOf(tokenId) == user;
        bool isApprove = getApproved(tokenId) == user;
        bool isApprovalForAll = isApprovedForAll(ownerOf(tokenId),user);
        return (isOwner || isApprove || isApprovalForAll);
    }
}

error LoanErrorQuantityUnavailable(address user, uint256 tokenId, uint256 amountRequest, uint256 avaiableAmount);

contract SolomonTreasury is AccessControl {
    using SafeERC20 for IERC20;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    uint256 public constant ONE = 1e18;
    uint256 public constant SECONDS_PER_YEAR = 31536000; 

    IERC20  public immutable token;
    CycloneERC721Token public immutable scNFT;

    uint256 public constant LIQUIDATION_THRESHOLD = 8000;

    uint256 public totalReserves;    
    uint256 public totalBorrowed;
    uint256 public totalDisposited;


    uint256 public borrowIndex = ONE; // Index starting at 1.0 (1e18)
    uint256 public lastUpdateTimestamp;


    uint256 public baseRate;        // R0: Annual interest rate when U = 0
    uint256 public kinkRate;        // Rkink: Annual interest rate at Ukink
    uint256 public maxRate;         // Rmax: Annual interest rate when U = 100%
    uint256 public kinkUtilization; // Ukink: Optimal utilization rate (e.g., 80% = 0.8 * 1e18)
    uint256 public reserveFactor;   // Reserve factor (e.g., 10% = 0.1 * 1e18)


    // Deposit Information
    struct DepositInfo {
        uint256 principal; // Principal amount deposited
        uint256 indexAtDeposit; // BorrowIndex at the time of deposit
    }
    mapping(address => DepositInfo) public deposits;

    // Borrow Information
    struct BorrowInfo {
        uint256 principal; // Principal amount borrowed
        uint256 collateralTokenId; 
        uint256 indexAtBorrow; // BorrowIndex at the time of borrow
    }
    
    mapping(address => BorrowInfo) public borrows;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 principal, uint256 reward);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);
    event AccrueInterest(uint256 newBorrowIndex, uint256 borrowRate);
    event AdminWithdrawCollateral(address indexed borrower, uint256 collateralTokenId, string reason);
    event WithdrawReserves(address indexed recipient, uint256 amount);
    event ReserveUpdated(uint256 amount);


    // CONSTRUCTOR

    constructor(
        IERC20 _token,
        CycloneERC721Token _scNFT,
        uint256 _baseRate,
        uint256 _kinkRate,
        uint256 _maxRate,
        uint256 _kinkUtilization,
        uint256 _reserveFactor
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(ADMIN_ROLE, _msgSender());

        token    = _token;
        scNFT    = _scNFT;
        baseRate = _baseRate;
        kinkRate = _kinkRate;
        maxRate  = _maxRate;
        kinkUtilization = _kinkUtilization;
        reserveFactor   = _reserveFactor;

        lastUpdateTimestamp = block.timestamp;

        require(_kinkUtilization <= ONE, "Kink utilization must be <= 100%");
        require(_reserveFactor < ONE, "Reserve factor must be < 100%");
    }


    // INTEREST RATE CALCULATION FUNCTIONS

    function getUtilizationRate() public view returns(uint256) {
        if (totalDisposited == 0) return 0;
        return (totalBorrowed * ONE) / totalDisposited;
    }
   


    function getBorrowRate() public view returns(uint256) {
        uint256 utilizationRate = getUtilizationRate();
        if (utilizationRate < kinkUtilization) {
            uint256 slope1 = ((kinkRate - baseRate) * ONE) / kinkUtilization;
            return baseRate + (utilizationRate * slope1) / ONE;
        } else {
            uint256 utilizationAboveKink = utilizationRate - kinkUtilization;
            uint256 slope2 = ((maxRate - kinkRate) * ONE) / (ONE - kinkUtilization);
            return kinkRate + (utilizationAboveKink * slope2) / ONE;
        }
    }


    function getSupplyRate() public view returns(uint256) {
        uint256 factor = (ONE - reserveFactor);
        uint256 utilizationRate = getUtilizationRate();
        uint256 borrowRate = getBorrowRate();
        uint256 term1 = (borrowRate * utilizationRate) / ONE;
        return (term1 * factor) / ONE;
    }


    // ACCRUAL LOGIC

    function accrueInterest() public {

        uint256 timeElapsed = block.timestamp - lastUpdateTimestamp;
        if (timeElapsed == 0) return;

        uint256 borrowRate = getBorrowRate(); 

        // Calculate index increase (old logic)
        uint256 ratePerSecond = borrowRate / SECONDS_PER_YEAR; 

        uint256 oldBorrowIndex = borrowIndex;
        uint256 indexIncrease = (borrowIndex * ratePerSecond * timeElapsed) / ONE;
        uint256 newBorrowIndex = borrowIndex + indexIncrease;
        
        // 1. Tính toán Lãi suất tích lũy (Gross Interest)
        // Lãi suất = totalBorrowed * (indexIncrease / oldBorrowIndex) - totalBorrowed
        uint256 grossInterestAccrued = (totalBorrowed * (newBorrowIndex - oldBorrowIndex)) / oldBorrowIndex;

        // 2. Tính toán Dự trữ (Reserves)
        // Dự trữ = Gross Interest * reserveFactor
        uint256 reserveAmount = (grossInterestAccrued * reserveFactor) / ONE;
        
        // 3. Cập nhật Tổng Dự trữ
        totalReserves += reserveAmount;
        emit ReserveUpdated(reserveAmount);

        // 4. Cập nhật Borrow Index và Total Borrowed (old logic)
        borrowIndex = newBorrowIndex;
        lastUpdateTimestamp = block.timestamp;
        
        // Total Borrowed đã bao gồm phần lãi suất (Gross Interest)
        totalBorrowed += grossInterestAccrued; 

        emit AccrueInterest(newBorrowIndex, borrowRate);
    }



    // USER INTEREST diposit and reward
    function getDepositRewards(address user) public view returns (uint256) {
        DepositInfo storage userDeposit = deposits[user];
        if (userDeposit.principal == 0) return 0;
        
        // The index increase ratio for the depositor (scaled by 1 - reserveFactor)
        uint256 indexRatio = (borrowIndex * ONE) / userDeposit.indexAtDeposit;
        uint256 rewardRate = (indexRatio * (ONE - reserveFactor)) / ONE; // Adjust for reserve factor
        
        // Reward = Principal * (Reward Rate - 1)
        if (rewardRate <= ONE) return 0;
        
        uint256 netRewardRate = rewardRate - ONE;
        return (userDeposit.principal * netRewardRate) / ONE;
    }

    function deposit(uint256 amount) external  {
        accrueInterest(); 
        require(amount > 0, "Amount must be greater than zero");

        // Update user state
        DepositInfo storage userDeposit = deposits[msg.sender];

        if (userDeposit.principal == 0) {
            userDeposit.principal += amount;
        } else {
            uint256 currentRewards = getDepositRewards(msg.sender);
            userDeposit.principal += (amount + currentRewards);
        }

        userDeposit.indexAtDeposit = borrowIndex;

        totalDisposited += amount;
        
        // Transfer funds (Interaction)
        token.safeTransferFrom(msg.sender, address(this), amount);
        emit Deposit(msg.sender, amount); 
    }

    function withdraw(uint256 amount) external  {
        accrueInterest();

        DepositInfo storage userDeposit = deposits[msg.sender];
        require(userDeposit.principal >= amount, "Insufficient deposit");
        
        uint256 rewards = getDepositRewards(msg.sender);
        uint256 totalWithdrawAmount = amount + rewards;
        
        userDeposit.principal -= amount;
        if (userDeposit.principal == 0) {
            userDeposit.indexAtDeposit = 0; 
        }
        
        totalDisposited -= amount;

        token.safeTransfer(msg.sender, totalWithdrawAmount);
        emit Withdraw(msg.sender, amount, rewards);
    }

    // USER BORROWING & REPAYMENT FUNCTIONS

    function getDebtForUser(address user) public view returns (uint256) {
        BorrowInfo storage userBorrow = borrows[user];
        if (userBorrow.principal == 0) return 0;
        
        uint256 indexRatio = (borrowIndex * ONE) / userBorrow.indexAtBorrow;
        
        return (userBorrow.principal * indexRatio) / ONE;
    }

    function borrow(uint256 amount, uint256 collateralTokenId) external {
        // Update accrure
        accrueInterest(); 
        // Check if there are any outstanding debts.
        require(borrows[msg.sender].principal == 0, "Repay existing loan before borrowing again");

        // Check if it's ready to use.
        address approvedSpender = scNFT.getApprovedCollateral(collateralTokenId);
        require(approvedSpender == address(0), "Treasury is not approved for this NFT");
        // 

        require(token.balanceOf(address(this)) >= amount, "Pool is illiquid");
        require(amount > 0, "Amount must be greater than zero");
        uint256 tokenValue = scNFT.getTokenValue(collateralTokenId);

        uint256 maximumAvailable = (tokenValue * 70) / 100;
        if (amount > maximumAvailable) {
            revert LoanErrorQuantityUnavailable(msg.sender, collateralTokenId, amount, maximumAvailable);
        }

        scNFT.lockActivitiesForOwnerTokenCollateral(collateralTokenId);

        BorrowInfo storage userBorrow = borrows[msg.sender];

        userBorrow.collateralTokenId = collateralTokenId;
        userBorrow.principal = amount;
        userBorrow.indexAtBorrow = borrowIndex;
        
        totalBorrowed += amount;

        token.safeTransfer(msg.sender, amount);
        emit Borrow(msg.sender, amount);
    }

   
    function repay(uint256 amount) external {
        accrueInterest();

        BorrowInfo storage userBorrow = borrows[msg.sender];
        require(amount > 0, "Amount must be greater than zero");
        require(userBorrow.principal > 0, "No outstanding debt");

        uint256 totalDebt = getDebtForUser(msg.sender);
        uint256 amountToRepay = amount;

        // Repay all
        if (amountToRepay >= totalDebt) {
            amountToRepay = totalDebt; 
            token.safeTransferFrom(msg.sender, address(this), amountToRepay);
            scNFT.unLockActivitiesForOwnerTokenCollateral(userBorrow.collateralTokenId);
            delete borrows[msg.sender];
        } 
        // Pay in part
        else {
            token.safeTransferFrom(msg.sender, address(this), amountToRepay);

            uint256 remainingDebt = totalDebt - amountToRepay;
            uint256 indexRatio = (userBorrow.indexAtBorrow * ONE) / borrowIndex;
            userBorrow.principal = (remainingDebt * indexRatio) / ONE;
        }

        // Subtract total debt
        totalBorrowed -= amountToRepay;
        emit Repay(msg.sender, amountToRepay);
    }


    // ADMIN FUNCTION
    function setRateParameters(
        uint256 _baseRate,
        uint256 _kinkRate,
        uint256 _maxRate,
        uint256 _kinkUtilization
    ) external onlyRole(ADMIN_ROLE) {
        require(_kinkUtilization <= ONE, "Kink utilization must be <= 100%");
        
        baseRate = _baseRate;
        kinkRate = _kinkRate;
        maxRate = _maxRate;
        kinkUtilization = _kinkUtilization;
    }

    function setReserveFactor(uint256 _reserveFactor) external onlyRole(ADMIN_ROLE)  {
        require(_reserveFactor < ONE, "Reserve factor must be < 100%");
        reserveFactor = _reserveFactor;
    }

    function adminForceWithdrawCollateral(address borrower) 
        external 
        onlyRole(ADMIN_ROLE) 
    {
        accrueInterest(); 

        require(!checkLiquidationStatus(borrower),"Not yet ready for liquidation.");
        
        // Lấy thông tin khoản vay của người vay
        BorrowInfo storage loan = borrows[borrower];
        uint256 tockenId = loan.collateralTokenId;
        scNFT.withdrawCollateral(tockenId);
        
        delete borrows[borrower];
        emit AdminWithdrawCollateral(borrower,tockenId,"Over-debt");
    }

    function checkLiquidationStatus(address borrower) 
        public 
        view 
        returns (bool) 
    {
        // 1. Kiểm tra nợ và tài sản thế chấp
        uint256 totalDebt = getDebtForUser(borrower);
        if (totalDebt == 0) {
            return false;
        }
        
        BorrowInfo storage loan = borrows[borrower];
        if (loan.collateralTokenId == 0) {
            return false; 
        }

        uint256 saleKink = ((loan.principal * 95 * ONE) / 70) / ONE;
        if (saleKink < totalDebt) {
            return true;
        }
       return  false;
    }

    
    function withdrawReserves(address recipient, uint256 amount) 
        external 
        onlyRole(ADMIN_ROLE) 
    {
        require(amount > 0, "Amount must be greater than zero");
        
        require(amount <= totalReserves, "Amount exceeds total accumulated reserves");
        
        require(token.balanceOf(address(this)) >= amount, "Insufficient physical funds in pool");
        
        totalReserves -= amount;
        
        token.safeTransfer(recipient, amount);
        
        emit WithdrawReserves(recipient, amount);
    }

    function callback() public  {
    }

}
```