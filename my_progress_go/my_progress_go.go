package main

import (
    "fmt"
    "log"
    "net/http"
    "encoding/json"
    "github.com/gorilla/mux"
    "rsc.io/quote"
    "math/rand"
    "strconv"
)

type Article struct {
    Id string `json:"Id"`
    Title string `json:"Title"`
    Desc string `json:"desc"`
    Content string `json:"content"`
}

type ServiceStatus struct {
    Status string
}

type ServicePercentage struct {
    Percentage1 string
    Percentage2 string
}

// let's declare a global Articles array
// that we can then populate in our main function
// to simulate a database
var Articles []Article
var serviceStatus ServiceStatus
var message string
var servicePercentage ServicePercentage

// Hello returns a greeting for the named person.
func Hello(name string) string {
    // Return a greeting that embeds the name in a message.
    message := fmt.Sprintf("Hi, %v. Welcome!", name)
    return message
}

func returnAllArticles(w http.ResponseWriter, r *http.Request){
    fmt.Println("Endpoint Hit: returnAllArticles")
    json.NewEncoder(w).Encode(Articles)
}

func returnSingleArticle(w http.ResponseWriter, r *http.Request){
    vars := mux.Vars(r)
    key := vars["id"]

    fmt.Println(w, "Key: " + key)

     // return the article encoded as JSON
     for _, article := range Articles {
        if article.Id == key {
            json.NewEncoder(w).Encode(article)
        }
    }
}

func returnServiceStatus(w http.ResponseWriter, r *http.Request){
    
    serviceStatus := &ServiceStatus{Status: "OK"}

    b, err := json.Marshal(serviceStatus)
    if err != nil {
        fmt.Println(err)
        return
    }
    fmt.Println(string(b))

    // return the status encoded as JSON
    json.NewEncoder(w).Encode(serviceStatus)
}

func returnServicePercentage(w http.ResponseWriter, r *http.Request){
    
    // constants
    //
    min := 100
    max := 400
    var result1 string = strconv.Itoa( (rand.Intn(max - min) + min))

    // constants
    //
    minT := 15
    maxT := 32
    var result2 string = strconv.Itoa( (rand.Intn(maxT - minT) + minT))
        
    servicePercentage := &ServicePercentage{
        Percentage1: result1, Percentage2: result2}

    b, err := json.Marshal(servicePercentage)
    if err != nil {
        fmt.Println(err)
        return
    }
    fmt.Println(string(b))

    // return the status encoded as JSON
    json.NewEncoder(w).Encode(servicePercentage)
}

func homePage(w http.ResponseWriter, r *http.Request){
    fmt.Fprintf(w, "Welcome to the HomePage!")
    fmt.Println("Endpoint Hit: homePage")
    fmt.Println(quote.Go())
    fmt.Println(Hello("TEST"))
}

func handleRequests() {
    // creates a new instance of a mux router
    myRouter := mux.NewRouter().StrictSlash(true)

    http.HandleFunc("/", homePage)
    // add our articles route and map it to our 
    // returnAllArticles function like so
    http.HandleFunc("/all", returnAllArticles)
    myRouter.HandleFunc("/article/{id}", returnSingleArticle)
    myRouter.HandleFunc("/servicestatus", returnServiceStatus)
    myRouter.HandleFunc("/servicepercentage", returnServicePercentage)

     // finally, instead of passing in nil, we want
    // to pass in our newly created router as the second
    // argument
    log.Fatal(http.ListenAndServe(":8000", myRouter))
}

func main() {

    fmt.Println("Rest API v2.0 - Mux Routers")

    Articles = []Article{
        Article{Id: "1", Title: "Hello", Desc: "Article Description", Content: "Article Content"},
        Article{Id: "2", Title: "Hello 2", Desc: "Article Description", Content: "Article Content"},
    }

    handleRequests()
}
