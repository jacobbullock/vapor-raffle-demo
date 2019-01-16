var timer;
var maxIntervals = 15;
var colors = ["#CCCCCC","#333333","#990099"]; 
var index = 0;
var selectedEntry;

function confirmClear() {
    if(confirm("Are you sure you want to clear all winners?")) {
        $.get(
            "/raffles/" + $("#raffle").data("id") + "/clear_winners",
            {},
            function(data) {
                window.location = "/raffles/" + $("#raffle").data("id") + "/run"
            }
        );
    }
}

function start() {
    if(selectedEntry != null ) {
        selectedEntry.css("background-color", "#FFFFFF");
    }
    selectedEntry = null;
    index = 0;
    timer = window.setInterval(combItems, 500);
}

function combItems() {
    index += 1;

    var rand = Math.floor(Math.random()*colors.length);  

    if(index == maxIntervals) {
        clearInterval(timer);
        requestWinner();
        return;
    }
    
    var entry = randomEntry();
    entry.animate({
        backgroundColor: colors[rand],
      }, 150 );

    window.setTimeout(function() {
        if(selectedEntry == null || selectedEntry.data("id") != entry.data("id")) {
            entry.animate({
                backgroundColor: "#FFFFFF",
              }, 100 );
        }
    }, 1000);
}

function requestWinner() {
    $.get(
        "/raffles/" + $("#raffle").data("id") + "/select_winner",
        {},
        function(data) {
            console.log(data);
            var entryID = data.id;
            console.log(entryID);
            selectedEntry = $("#js-entry-"+entryID);
            selectedEntry.animate({
                backgroundColor: "#FF0000",
            }, 150 );
            selectedEntry.removeClass("js-entry");
            selectedEntry.addClass("winner");
        }
    );
}

function randomEntry() {
    var entries = $(".js-entry");
    return $(entries[Math.floor(Math.random()*entries.length)]);
}