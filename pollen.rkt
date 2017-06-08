#lang racket/base
(require racket/date txexpr pollen/setup pollen/decode hyphenate)
(provide (all-defined-out))

(module setup racket/base
  (provide (all-defined-out))
  (require pollen/setup racket/list)
  (define poly-targets '(html))
  (define block-tags (remove* '(div aside) default-block-tags)))

(define (root . items)
  (decode (txexpr 'root '() items)
          #:txexpr-elements-proc decode-paragraphs-no-breaks
          #:block-txexpr-proc (compose1 hyphenate wrap-hanging-quotes)
          #:string-proc (compose1 smart-quotes)
          #:exclude-tags '(style script)))

(define (decode-paragraphs-no-breaks elements)
  (decode-paragraphs elements #:linebreak-proc no-decode-linebreaks))

(define (no-decode-linebreaks elements)
  (decode-linebreaks elements " "))

(define (quotation #:person person #:source source . body)
  (case (current-poly-target)
    [(html) `(div ((class "quotation"))
                  (div "«" ,@body "»")
                  (div ((style "padding-left: 2em;"))
                       (i ,person " in " ,source)))]
    [else (list person source body)]))

(define (title . elements)
  (case (current-poly-target)
    [(html) `(h1 ,@elements)]
    [else elements]))

(define (emph . elements)
  (case (current-poly-target)
    [(html) `(i () ,@elements)]
    [else elements]))

(define (function . name)
  (case (current-poly-target)
    [(html) `(i ,@name)]
    [else name]))

(define (scare . saetz)
  (case (current-poly-target)
    [(html) `(span "‘" ,@saetz "’")]
    [else saetz]))

(define (first-use . term)
  (case (current-poly-target)
    [(html) `(em ,@term)]
    [else term]))

(define (aside . body)
  (case (current-poly-target)
    [(html) `(span ((class "sidenote"))
                   ,@body)]
    [else body]))
