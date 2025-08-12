;; Basic Staking Platform
;; A minimal contract to stake and withdraw STX

;; Error constants
(define-constant err-invalid-amount (err u100))
(define-constant err-insufficient-stake (err u101))

;; Track user stakes
(define-map stakes principal uint)
(define-data-var total-staked uint u0)

;; Function 1: Stake STX
(define-public (stake (amount uint))
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    ;; Transfer STX from user to contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    ;; Update stake mapping
    (map-set stakes tx-sender
             (+ (default-to u0 (map-get? stakes tx-sender)) amount))
    ;; Update total staked
    (var-set total-staked (+ (var-get total-staked) amount))
    (ok true)))

;; Function 2: Withdraw STX
(define-public (withdraw (amount uint))
  (let ((current-stake (default-to u0 (map-get? stakes tx-sender))))
    (begin
      (asserts! (> amount u0) err-invalid-amount)
      (asserts! (>= current-stake amount) err-insufficient-stake)
      ;; Transfer STX from contract to user
      (try! (stx-transfer? amount (as-contract tx-sender) tx-sender))
      ;; Update stake mapping
      (map-set stakes tx-sender (- current-stake amount))
      ;; Update total staked
      (var-set total-staked (- (var-get total-staked) amount))
      (ok true))))
