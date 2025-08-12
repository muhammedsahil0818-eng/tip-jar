;; On-Chain Marketplace Contract (Basic Version)
;; This contract allows listing and buying items.

;; Data structure for a listing
(define-map listings uint
  { seller: principal,
    price: uint,
    item-name: (string-ascii 50) })

;; Global listing ID counter
(define-data-var listing-counter uint u0)

;; Errors
(define-constant err-invalid-price (err u100))
(define-constant err-not-found (err u101))
(define-constant err-insufficient-payment (err u102))

;; 1. List an item for sale
(define-public (list-item (item-name (string-ascii 50)) (price uint))
  (begin
    (asserts! (> price u0) err-invalid-price)
    (var-set listing-counter (+ (var-get listing-counter) u1))
    (map-set listings (var-get listing-counter)
             { seller: tx-sender,
               price: price,
               item-name: item-name })
    (ok (var-get listing-counter))
  )
)

;; 2. Buy an item
(define-public (buy-item (listing-id uint))
  (let (
        (listing (map-get? listings listing-id))
       )
    (match listing
      listing-data
        (let (
              (seller (get seller listing-data))
              (price (get price listing-data))
             )
          (asserts! (>= (stx-get-balance tx-sender) price) err-insufficient-payment)
          (try! (stx-transfer? price tx-sender seller))
          (map-delete listings listing-id)
          (ok { purchased: listing-id, from: seller })
        )
      err-not-found
    )
  )
)


