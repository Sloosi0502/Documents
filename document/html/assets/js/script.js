let canEdit = false;
let currentJob = null;

window.addEventListener("message", function(event) {
  const data = event.data;

  switch (data.action) {
    case "open":
      $("#document").fadeIn(300);
      canEdit = data.data.canEdit;
      currentJob = data.data.job;

      // Logo
      $(".img-bg").attr("src", `./assets/img/${currentJob}.png`);
      $(".stamp").attr("src", `./assets/img/${currentJob}.png`);

      // Header
      $("#header_title").text(data.data.header.title);
      $("#header_subtitle_department").text(data.data.header.subtitle.department);
      $("#header_subtitle_name").text(data.data.header.subtitle.name);
      $("#header_subtitle_zone").text(data.data.header.subtitle.zone);
      $("#header_subtitle_postal").text(data.data.header.subtitle.postal);

      // Body
      $("#body_title").text(data.data.body.title);
      $("#body_description").text(data.data.body.description);
      $("#body_title").attr("contenteditable", canEdit);
      $("#body_description").attr("contenteditable", canEdit);

      // Footer
      $("#footer_date").text(data.data.footer.date);
      $("#footer_signature").text(data.data.footer.signature);
      $("#footer_name").text(data.data.footer.name);

      break;
    case "close":
      closeDocument();
      break;
  }
});

window.addEventListener("keydown", function(event) {
  if (event.key === "Escape") {
    closeDocument();
  } else if (event.key === "Enter") {
    if (!canEdit) return;
    $.post(`https://${GetParentResourceName()}/save`, JSON.stringify({
      job: currentJob,
      header: {
        title: $("#header_title").text(),
        subtitle: {
          department: $("#header_subtitle_department").text(),
          name: $("#header_subtitle_name").text(),
          zone: $("#header_subtitle_zone").text(),
          postal: $("#header_subtitle_postal").text()
        },
      },
      body: {
        title: $("#body_title").text(),
        description: $("#body_description").text()
      },
      footer: {
        date: $("#footer_date").text(),
        signature: $("#footer_signature").text(),
        name: $("#footer_name").text()
      }
    }));

    closeDocument();
  }
});

function closeDocument() {
  $("#document").fadeOut(300);
  $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({}));
}