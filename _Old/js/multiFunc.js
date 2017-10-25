$(document).ready(function()
{
	$("body").css({"height" : ($(window).height())});
	if(localStorage.getItem("editPassword"))
	{
		//alert("setting pw");
		$("#editPassword").val(localStorage.getItem("editPassword"));
	}

	$("#createUserSubmit").click(function()
	{
		if(!$("#username").val())
		{
			alert("Please use a valid username");
			return false;
		}

		if($("#username").val() == "")
		{
			alert("Please use a valid username");
			return false;
		}

		if($("#username").val() == " ")
		{
			alert("Please use a valid username");
			return false;
		}
		
		/*if($("#savePW:checked").val() == "true")
		{
			//alert("saved pw");
			localStorage.setItem("editPassword", ($("#editPassword").val()));
		}
		else
		{
			localStorage.setItem("editPassword", "");
		}*/

		$.ajax({ 
		    type: "POST", 
		    url: "multiFunc.pl", 
		    data: {"method": "newUserDo", "username" : ($("#username").val()), "group": ($("#group").val()), "rank": ($("#rank").val()), "accessPW" : localStorage.getItem("editPassword")}, 
		    success: function(data) 
		    { 
		    	if(data == "success")
		    	{
		    		$("#username").val("");
		    		alert("Successfully created user; user put onto auto-queue");
		    		window.location.href = "http://the-confederation.net/index/profiles/0-70";
		    	}
		    	if(data.indexOf('Duplicate entry') > -1)
		    	{
		    		alert("User exists already, check inactives?");
		    	}
		    	else
		    	{
		    		alert("error: " + data);
		    	}
		    }
		});
	});

	$("#editUserSubmit").click(function()
	{
		$.ajax({ 
		    type: "POST", 
		    url: "multiFunc.pl", 
		    data: {"method": "editUserDo", "username" : ($("#username").val()), "group": ($("#group").val()), "rank": ($("#rank").val()), "accessPW" : localStorage.getItem("editPassword"), "league" : ($("#league").val()), "race" : ($("#race").val()), "api" : ($("#api").val()), "ucoz" : ($("#ucoz").val()), "stream": ($("#stream").val()), "active" : ($("#error").val())}, 
		    success: function(data) 
		    { 
		    	if(data == "successe")
		    	{
		    		alert("edits saved");
		    		window.close();
		    	}
		    	else
		    	{
		    		alert("error: " + data);
		    	}
		    }
		});
	});

	$("#giveAward").click(function()
	{
		$.ajax({ 
		    type: "POST", 
		    url: "multiFunc.pl", 
		    data: {"method": "addAwardDo", "username" : ($("#username").val()), "awardType" : ($("#awardType").val()), "reason" : ($("#reason").val()), "accessPW" : (localStorage.getItem("editPassword"))}, 
		    success: function(data) 
		    { 
		    	if(data == "successe")
		    	{
		    		alert("award given");
		    		window.location.href = window.location.href;
		    	}
		    	else
		    	{
		    		alert("error: " + data);
		    	}
		    }
		});
	});

	$(".viewInfo").click(function()
	{
		//alert(this.id);
		//viewInfo_$dbgUsername\_rank
		var wins = this.id + "_wins";
		var wins = parseInt($("#" + wins).html());
		var losses = this.id + "_losses";
		var losses = parseInt($("#" + losses).html());

		var WLratio = (wins/(wins+losses)) * 100;
		var WLratio = parseFloat(WLratio).toFixed(3);
		if(WLratio >= 50)
		{
			WLcolor = "green";
		}
		else
		{
			WLcolor = "red";
		}

		var sourceRank = this.id + "_rank";
		var sourceBnet = this.id + "_bnet";
		var sourceBnet = $("#"+sourceBnet).html();
		var sourceuCoz = this.id + "_ucoz";
		var sourceuCoz = $("#"+sourceuCoz).html();
		var sourceStream = this.id + "_stream";
		var sourceStream = $("#"+sourceStream).html();
		var sourceName = (this.id).substring(9);
		var awardsListed = this.id + "_awards";
		var awardsListed = $("#"+awardsListed).html();

		var adminLoggedIn = localStorage.getItem("editPassword");
		if(!adminLoggedIn)
		{
			adminLoggedIn = "";
		}
		else
		{
			adminLoggedIn = "&nbsp;&nbsp;<a href='http://teamconfed.com/api/multiFunc.pl?method=editUser&username=" + sourceName + "&accessPW=" + localStorage.getItem("editPassword") + "' target='_blank'>Edit User</a><br/>&nbsp;&nbsp;<a href='http://teamconfed.com/api/multiFunc.pl?method=addAward&username=" + sourceName + "&accessPW=" + localStorage.getItem("editPassword") + "' target='_blank'>Add Award</a><br/><br/>";
		}
		if((!awardsListed)||((awardsListed.length) <= 2))
		{
			var awardsListed = "&nbsp;&nbsp;None yet! Learn more <a href='http://the-confederation.net/index/awards/0-15' target='_blank'>here</a>";
		}
		$("#popupRank").html('<center><span class="sourceNameFont">' + sourceName + '</span></center>'+
			'<br/><span style="font-size:12px;">&nbsp;&nbsp;- ' + $("#thisGroup").html() + ', ' + $("#"+sourceRank).html() + 
			"<br/>&nbsp;&nbsp;- 1v1 Wins: " + wins + "<br/>&nbsp;&nbsp;- 1v1 Losses: " + losses + 
			"</br>&nbsp;&nbsp;- Win ratio: <font color='" + WLcolor + "'>" + WLratio + "%</font></span>" + 
			"<br/><br/><span class='sourceNameFont2'><br/><center>Awards</center></span>"+
			"<div style='font-size:12px;margin-top:10px !important;'>" + awardsListed + "</div>"+
			"<span class='sourceNameFont2'><br/><div style='height:10px'></div><center>Other</center></span>"+
			"<div style='font-size:12px;margin-top:10px !important;'>&nbsp;&nbsp;Starcraft Profile: <a href='" + sourceBnet + "' target='_blank'>link</a>"+
			"<br/>&nbsp;&nbsp;Forum Profile: <a href='" + sourceuCoz + "' target='_blank'>link</a>"+
			"<!--<br/>&nbsp;&nbsp;Twitch: <a href='" + sourceStream + "' target='_blank'>link</a>-->"+
			"<br/><br/><br/>"+ adminLoggedIn +
			"</div>");
		$("#popup").show();
	});
	$("#closePopup").click(function()
	{
		$("#popup").hide();
	});
});