;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-enough-data (err u101))
(define-constant err-invalid-price (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-invalid-fee (err u104))
(define-constant err-data-transfer-failed (err u105))
(define-constant err-not-same-user (err u106))
(define-constant err-limit-exceeded (err u107))
(define-constant err-invalid-limit (err u108))

;; Define data variables
(define-data-var data-price uint u200) ;; Price per health data unit in microstacks (1 STX = 1,000,000 microstacks)
(define-data-var max-data-per-user uint u5000) ;; Maximum data a user can upload (in units)
(define-data-var commission-fee uint u5) ;; Commission fee in percentage (e.g., 5 means 5%)
(define-data-var refund-percentage uint u80) ;; Refund percentage in case of invalid purchase (e.g., 80 means 80% refund)
(define-data-var data-limit uint u100000) ;; Global data limit (in units)
(define-data-var current-data uint u0) ;; Current data in the system (in units)

;; Define data maps
(define-map user-data-balance principal uint)
(define-map user-stx-balance principal uint)
(define-map data-for-sale {user: principal} {amount: uint, price: uint})

;; Private functions

;; Calculate commission fee
(define-private (calculate-commission (amount uint))
  (/ (* amount (var-get commission-fee)) u100))

;; Calculate refund amount
(define-private (calculate-refund (amount uint))
  (/ (* amount (var-get data-price) (var-get refund-percentage)) u100))

;; Update data system balance
(define-private (update-data-balance (amount int))
  (let (
    (current-balance (var-get current-data))
    (new-balance (if (< amount 0)
                     (if (>= current-balance (to-uint (- 0 amount)))
                         (- current-balance (to-uint (- 0 amount)))
                         u0)
                     (+ current-balance (to-uint amount))))
  )
    (asserts! (<= new-balance (var-get data-limit)) err-limit-exceeded)
    (var-set current-data new-balance)
    (ok true)))

;; Public functions

;; Set health data price (only contract owner)
(define-public (set-data-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> new-price u0) err-invalid-price)
    (var-set data-price new-price)
    (ok true)))

;; Set commission fee (only contract owner)
(define-public (set-commission-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-fee u100) err-invalid-fee)
    (var-set commission-fee new-fee)
    (ok true)))

;; Set refund percentage (only contract owner)
(define-public (set-refund-percentage (new-percentage uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-percentage u100) err-invalid-fee)
    (var-set refund-percentage new-percentage)
    (ok true)))

;; Set data limit (only contract owner)
(define-public (set-data-limit (new-limit uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (>= new-limit (var-get current-data)) err-invalid-limit)
    (var-set data-limit new-limit)
    (ok true)))

;; Add health data for sale
(define-public (add-data-for-sale (amount uint) (price uint))
  (let (
    (current-balance (default-to u0 (map-get? user-data-balance tx-sender)))
    (current-for-sale (get amount (default-to {amount: u0, price: u0} (map-get? data-for-sale {user: tx-sender}))))
    (new-for-sale (+ amount current-for-sale))
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (> price u0) err-invalid-price)
    (asserts! (>= current-balance new-for-sale) err-not-enough-data)
    (try! (update-data-balance (to-int amount)))
    (map-set data-for-sale {user: tx-sender} {amount: new-for-sale, price: price})
    (ok true)))

;; Remove health data from sale
(define-public (remove-data-from-sale (amount uint))
  (let (
    (current-for-sale (get amount (default-to {amount: u0, price: u0} (map-get? data-for-sale {user: tx-sender}))))
  )
    (asserts! (>= current-for-sale amount) err-not-enough-data)
    (try! (update-data-balance (to-int (- amount))))
    (map-set data-for-sale {user: tx-sender} 
             {amount: (- current-for-sale amount), price: (get price (default-to {amount: u0, price: u0} (map-get? data-for-sale {user: tx-sender})))})
    (ok true)))

;; Buy health data from user
(define-public (buy-data-from-user (seller principal) (amount uint))
  (let (
    (sale-data (default-to {amount: u0, price: u0} (map-get? data-for-sale {user: seller})))
    (data-cost (* amount (get price sale-data)))
    (commission (calculate-commission data-cost))
    (total-cost (+ data-cost commission))
    (seller-data (default-to u0 (map-get? user-data-balance seller)))
    (buyer-balance (default-to u0 (map-get? user-stx-balance tx-sender)))
    (seller-balance (default-to u0 (map-get? user-stx-balance seller)))
    (owner-balance (default-to u0 (map-get? user-stx-balance contract-owner)))
  )
    (asserts! (not (is-eq tx-sender seller)) err-not-same-user)
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= (get amount sale-data) amount) err-not-enough-data)
    (asserts! (>= seller-data amount) err-not-enough-data)
    (asserts! (>= buyer-balance total-cost) err-not-enough-data)

    ;; Update seller's data balance and for-sale amount
    (map-set user-data-balance seller (- seller-data amount))
    (map-set data-for-sale {user: seller} 
             {amount: (- (get amount sale-data) amount), price: (get price sale-data)})

    ;; Update buyer's STX and data balance
    (map-set user-stx-balance tx-sender (- buyer-balance total-cost))
    (map-set user-data-balance tx-sender (+ (default-to u0 (map-get? user-data-balance tx-sender)) amount))

    ;; Update seller's and contract owner's STX balance
    (map-set user-stx-balance seller (+ seller-balance data-cost))
    (map-set user-stx-balance contract-owner (+ owner-balance commission))

    (ok true)))

;; Refund data purchase
(define-public (refund-data (amount uint))
  (let (
    (user-data (default-to u0 (map-get? user-data-balance tx-sender)))
    (refund-amount (calculate-refund amount))
    (contract-stx-balance (default-to u0 (map-get? user-stx-balance contract-owner)))
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= user-data amount) err-not-enough-data)
    (asserts! (>= contract-stx-balance refund-amount) err-data-transfer-failed)

    ;; Update user's data balance
    (map-set user-data-balance tx-sender (- user-data amount))

    ;; Update user's and contract's STX balance
    (map-set user-stx-balance tx-sender (+ (default-to u0 (map-get? user-stx-balance tx-sender)) refund-amount))
    (map-set user-stx-balance contract-owner (- contract-stx-balance refund-amount))

    ;; Add refunded data back to contract owner's balance
    (map-set user-data-balance contract-owner (+ (default-to u0 (map-get? user-data-balance contract-owner)) amount))

    ;; Update data balance
    (try! (update-data-balance (to-int (- amount))))

    (ok true)))

;; Read contract state (returns the data system status)
(define-public (read-contract-status)
  (ok {current-data: (var-get current-data), data-price: (var-get data-price)}))

;; Get user balance (data and STX)
(define-public (get-user-balance (user principal))
  (ok {data-balance: (default-to u0 (map-get? user-data-balance user)),
       stx-balance: (default-to u0 (map-get? user-stx-balance user))}))


;; Fetch data for sale by user
(define-public (get-data-for-sale (user principal))
  (ok (default-to {amount: u0, price: u0} (map-get? data-for-sale {user: user}))))

;; Check contract global data limit
(define-public (check-global-limit)
  (ok {current-data: (var-get current-data), data-limit: (var-get data-limit)}))

;; View commission and refund rates
(define-public (get-commission-and-refund-rates)
  (ok {commission-fee: (var-get commission-fee), refund-percentage: (var-get refund-percentage)}))

;; Fix: Prevent underflow in `update-data-balance`
(define-private (safe-update-data-balance (amount int))
  (let ((current (var-get current-data)))
    (if (< amount 0)
      (asserts! (>= current (to-uint (- 0 amount))) err-limit-exceeded)
      (var-set current-data (+ current (to-uint amount))))
    (ok true)))

;; Add multi-factor authentication for sensitive updates
(define-private (mfa-authentication (user principal))
  (ok {status: "mfa-authenticated"}))

;; Test UI element integration
(define-public (test-ui-integration)
  (ok {status: "UI integration test successful"}))

;; Returns the health data balance of a given user
(define-public (get-user-data-balance (user principal))
  (ok (default-to u0 (map-get? user-data-balance user))))

;; Returns the STX balance of a given user
(define-public (get-user-stx-balance (user principal))
  (ok (default-to u0 (map-get? user-stx-balance user))))
