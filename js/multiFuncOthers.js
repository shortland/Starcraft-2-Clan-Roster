$(document).ready(function()
{
	$("body").css({"height" : ($(window).height())});
	if(localStorage.getItem("editPassword"))
	{
		//alert("setting pw");
		$("#onlyIfLogged").show();
		$("#spcLog").hide();

		$("#editPassword").val(localStorage.getItem("editPassword"));
	}

	//$("#popup").css({"left" : "275px"});

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
		    url: "multiFuncOthers.pl", 
		    data: {"method": "newUserDo", "username" : ($("#username").val()), "group": ($("#group").val()), "rank": ($("#rank").val()), "accessPW" : localStorage.getItem("editPassword")}, 
		    success: function(data) 
		    { 
		    	if(data == "success")
		    	{
		    		$("#username").val("");
		    		alert("Successfully created user; user put onto auto-queue");
		    		window.history.go(-1);
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
		    url: "multiFuncOthers.pl", 
		    data: {"method": "editUserDo", "username" : ($("#username").val()), "group": ($("#group").val()), "rank": ($("#rank").val()), "accessPW" : ($("#editPassword").val()), "league" : ($("#league").val()), "race" : ($("#race").val()), "api" : ($("#api").val()), "ucoz" : ($("#ucoz").val()), "stream": ($("#stream").val()), "active" : ($("#error").val())}, 
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
		    url: "multiFuncOthers.pl", 
		    data: {"method": "addAwardDo", "username" : ($("#username").val()), "awardType" : ($("#awardType").val()), "reason" : ($("#reason").val()), "accessPW" : ($("#accessPWset").val())}, 
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
		var WLratio = parseFloat(WLratio).toFixed(0);
		if(WLratio == "NaN")
		{
			WLratio = 0;
		}
		if(WLratio >= 50)
		{
			WLcolor = "green";
		}
		else
		{
			WLcolor = "red";
		}

		var sourceRank = $("#" + this.id + "_rank").html();
		var sourceRank = sourceRank.replace(/([a-z])([A-Z])/g, '$1 $2')
		var sourceBnet = $("#" + this.id + "_bnet").html();
		var sourceuCoz = $("#" + this.id + "_ucoz").html();
		var sourceStream = $("#" + this.id + "_stream").html();
		var sourceName = (this.id).substring(9);
		var awardsListed = $("#" + this.id + "_awards").html();
		var awardsListed = awardsListed.replace(/tablez/g, "table");
		var awardsListed = awardsListed.replace(/trz/g, "tr");
		var awardsListed = awardsListed.replace(/tdz/g, "td");
		var sourceGroup = $("#" + this.id + "_group").html();
		var sourceBnetLeaguePic = $("#" + this.id + "_bnetLeague").html();
		var sourceBnetPic = $("#" + this.id + "_bnetPic").html();
		var sourceBnetPicXoff = ((parseInt($("#" + this.id + "_bnetXoff").html())/90)*50);
		var sourceBnetPicYoff = ((parseInt($("#" + this.id + "_bnetYoff").html())/90)*50);

		var adminLoggedIn = localStorage.getItem("editPassword");
		if(!adminLoggedIn)
		{
			adminLoggedIn = "";
			ifislogged = "20";
		}
		else
		{
			ifislogged = "50";
			adminLoggedIn = "<tr><td>Edit User:</td><td>&nbsp;&nbsp;<a href='http://teamconfed.com/api/multiFuncOthers.pl?method=editUser&username=" + sourceName + "&accessPW=" + localStorage.getItem("editPassword") + "' target='_blank'>link</a></td></tr><tr><td>Add Award</td><td>&nbsp;&nbsp;<a href='http://teamconfed.com/api/multiFuncOthers.pl?method=addAward&username=" + sourceName + "&accessPW=" + localStorage.getItem("editPassword") + "' target='_blank'>link</a></td></tr>";
		}
		if((!awardsListed)||((awardsListed.length) <= 2))
		{
			//var awardsListed = "&nbsp;&nbsp;None yet, learn more <a href='http://the-confederation.net/index/awards/0-15' target='_blank'>here</a>";
		}
		$("#popupRank").html('' +
			'<table style="margin-left:20px !important;width:275px !important;">' +
			'<tr>' +
			'<td><div style="width:70px !important;"><img class="leagueBorderImage" src="../images/blizzard/' + sourceBnetLeaguePic + '-et.png" width="62px" height="62px" /><div style="position:relative;top:-58px;left:6px;z-index:6;width:50px;height:50px;background: url(../images/blizzard/' + sourceBnetPic + '-90.jpg) '+sourceBnetPicXoff+'px '+sourceBnetPicYoff+'px;" ></div><div style="text-decoration:underline;font-weight:bold;text-align:center;position:relative;top:-30px;">Awards</div></div></td>' +
			'<td style="vertical-align: top; padding-left: 10px !important;width:110px !important;"><div class="sourceNameFont" style="text-overflow: ellipsis; width: 100px !important; overflow: hidden; white-space: nowrap;">' + sourceName + '</div><br/><span>' + sourceGroup + ',<br/>' + sourceRank + '</span></td>' +
			'<td style="vertical-align: top; padding-left: 10px !important;width:100px !important;"><div style="width:100px;"><table><tr><td colspan="2" style="text-decoration:underline;font-weight:bold;text-align:center;">Statistics</td></tr><tr><td colspan="2">&nbsp;</td></tr><tr><td>1v1 Wins:</td><td>&nbsp;&nbsp;' + wins + '</td></tr><tr><td>1v1Losses:</td><td>&nbsp;&nbsp;' + losses + '</td></tr><tr><td>W/L Ratio:</td><td><span style="color:' + WLcolor + '">&nbsp;&nbsp;' + WLratio + '%</span></td></tr><tr><td colspan="2">&nbsp;</td></tr><tr><td colspan="2">&nbsp;</td></tr><tr><td colspan="2" style="text-align:center;text-decoration:underline;">Links</td></tr><tr><td colspan="2">&nbsp;</td></tr><tr><td>SC2 Profile:</td><td>&nbsp;&nbsp;<a href="' + sourceBnet + '" target="_blank">link</a></td></tr><tr><td>Forum:</td><td>&nbsp;&nbsp;<a href="' + sourceuCoz + '" target="_blank">link</a></td></tr>' + adminLoggedIn + '</table></div></td>' +
			'</tr>' +
			'<tr style="vertical-align: top;">' +
			'<td style="vertical-align: top;position:relative;top:-'+ifislogged+'px;">' + awardsListed + '</td>' +
			'<td style="vertical-align: top;"></td>' +
			'<td style="vertical-align: top;"></td>' +
			'</tr>' +
			'</table>' +
			'</div>');
			//"<br/><br/><span class='sourceNameFont2'><br/><center>Awards</center></span>"+
			//"<div style='font-size:12px;margin-top:10px !important;'>" + awardsListed + "</div>"+
			//"<span class='sourceNameFont2'><br/><div style='height:10px'></div><center>Other</center></span>"+
			//"<div style='font-size:12px;margin-top:10px !important;'>&nbsp;&nbsp;Starcraft Profile: <a href='" + sourceBnet + "' target='_blank'>link</a>"+
			//"<br/>&nbsp;&nbsp;Forum Profile: <a href='" + sourceuCoz + "' target='_blank'>link</a>"+
			//"<!--<br/>&nbsp;&nbsp;Twitch: <a href='" + sourceStream + "' target='_blank'>link</a>-->"+
			//"</div>");
		$(".leagueBorderImage").css({"margin-left" : "20px"});
		//$("#popup").show();
	});

	/*$("#popupRank").on("click", "#popupRank", function(event)
	{
		//alert("test");
		$(".leagueBorderImage").animate({"margin-left" : "20px"}, 0);
	});*/

	$("#closePopup").click(function()
	{
		$("#popup").hide();
	});

});