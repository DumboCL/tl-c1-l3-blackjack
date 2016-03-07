$(document).ready(function() {
  player_hits();
  player_stays();
  dealer_hits();
});

function player_hits() {
  $(document).on("click", "form#hit_form input", function() {
    alert("player hits!")
    $.ajax({
      type: 'POST',
      url: '/hit'
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });
    return false;
  });
}

function player_stays() {
  $(document).on("click", "form#stay_form input", function() {
    alert("player stays!")
    $.ajax({
      type: 'POST',
      url: '/stay'
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });
    return false;
  });
}

function dealer_hits() {
  $(document).on("click", "form#dealer_hit_form input", function() {
    alert("dealer hits!")
    $.ajax({
      type: 'POST',
      url: '/dealer/hit'
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });
    return false;
  });
}