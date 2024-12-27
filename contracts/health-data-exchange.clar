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

