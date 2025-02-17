;; Milestone Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-already-completed (err u103))

;; Data Variables
(define-data-var milestone-nonce uint u0)

;; Data Maps
(define-map milestones
  { milestone-id: uint }
  {
    campaign-id: uint,
    description: (string-utf8 500),
    target-amount: uint,
    completed: bool
  }
)

;; Public Functions

;; Add a milestone
(define-public (add-milestone (campaign-id uint) (description (string-utf8 500)) (target-amount uint))
  (let
    (
      (milestone-id (var-get milestone-nonce))
      (campaign (unwrap! (contract-call? .campaign get-campaign campaign-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get creator campaign)) err-unauthorized)
    (map-set milestones
      { milestone-id: milestone-id }
      {
        campaign-id: campaign-id,
        description: description,
        target-amount: target-amount,
        completed: false
      }
    )
    (var-set milestone-nonce (+ milestone-id u1))
    (ok milestone-id)
  )
)

;; Complete a milestone
(define-public (complete-milestone (milestone-id uint))
  (let
    (
      (milestone (unwrap! (map-get? milestones { milestone-id: milestone-id }) err-not-found))
      (campaign (unwrap! (contract-call? .campaign get-campaign (get campaign-id milestone)) err-not-found))
    )
    (asserts! (is-eq tx-sender (get creator campaign)) err-unauthorized)
    (asserts! (not (get completed milestone)) err-already-completed)
    (map-set milestones
      { milestone-id: milestone-id }
      (merge milestone { completed: true })
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get milestone details
(define-read-only (get-milestone (milestone-id uint))
  (ok (unwrap! (map-get? milestones { milestone-id: milestone-id }) err-not-found))
)

;; Initialize contract
(begin
  (var-set milestone-nonce u0)
)

