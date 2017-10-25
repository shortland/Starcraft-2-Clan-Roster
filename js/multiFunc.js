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
		    url: "multiFunc.pl", 
		    data: {"method": "newUserDo", "username" : ($("#username").val()), "group": ($("#group").val()), "rank": ($("#rank").val()), "accessPW" : localStorage.getItem("editPassword")}, 
		    success: function(data) 
		    { 
		    	if(data == "success")
		    	{
		    		$("#username").val("");
		    		alert("Successfully created user; user put onto auto-queue");
		    		window.location.href = "http://teamconfed.com/api/multiFunc.pl?method=showGroupsW";
		    	}
		    	if(data.indexOf('Duplicate entry') > -1)
		    	{
		    		alert("User exists already, check inactives?");
		    	}
		    	else
		    	{
		    		alert("Response: " + data);
		    	}
		    }
		});
	});

	$("#editUserSubmit").click(function()
	{
		$.ajax({ 
		    type: "POST", 
		    url: "multiFunc.pl", 
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
		    		alert("Response: " + data);
		    	}
		    }
		});
	});

	$("#giveAward").click(function()
	{
		$.ajax({ 
		    type: "POST", 
		    url: "multiFunc.pl", 
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
		    		alert("Response: " + data);
		    	}
		    }
		});
	});

	$(".viewInfo").click(function(e)
	{
		//alert(event.pageX);
		if(!e){ e = window.event; }
		if(e.pageX < 400) {
			if($(window).height()-250 < e.pageY) {
				$("#popup").animate({"left" : e.pageX+20, "top" : e.pageY-200},0);
			}
			else {
				$("#popup").animate({"left" : e.pageX+20, "top" : e.pageY+20}, 0);
			}
		}
		else {
			if($(window).height()-250 < e.pageY) {
				$("#popup").animate({"left" : e.pageX-360, "top" : e.pageY-200},0);
			}
			else {
				$("#popup").animate({"left" : e.pageX-360, "top" : e.pageY+20}, 0);
			}
		}

		//alert(event.pageX);
		//$("#popup").css({"left" : "", "top" : ""});
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
		//

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
		var sourceBnetPicXoff = ((parseInt($("#" + this.id + "_bnetXoff").html()) / 90) * 50);
		var sourceBnetPicYoff = ((parseInt($("#" + this.id + "_bnetYoff").html()) / 90) * 50);

		var adminLoggedIn = localStorage.getItem("editPassword");
		if(!adminLoggedIn)
		{
			adminLoggedIn = "";
			ifislogged = "20";
		}
		else
		{
			ifislogged = "50";
			adminLoggedIn = "<tr><td>Edit User:</td><td>&nbsp;&nbsp;<a href='http://teamconfed.com/api/multiFunc.pl?method=editUser&username=" + sourceName + "&accessPW=" + localStorage.getItem("editPassword") + "' target='_blank'>link</a></td></tr><tr><td>Add Award</td><td>&nbsp;&nbsp;<a href='http://teamconfed.com/api/multiFunc.pl?method=addAward&username=" + sourceName + "&accessPW=" + localStorage.getItem("editPassword") + "' target='_blank'>link</a></td></tr>";
		}
		if((!awardsListed)||((awardsListed.length) <= 2))
		{
			//var awardsListed = "&nbsp;&nbsp;None yet, learn more <a href='http://the-confederation.net/index/awards/0-15' target='_blank'>here</a>";
		}
		$("#popupRank").html('' +
			'<table style="margin-left:20px !important;width:275px !important;">' +
			'<tr>' +
			'<td style="display:none;"><div style="width:70px !important;"><img class="leagueBorderImage" src="../images/blizzard/' + sourceBnetLeaguePic + '-et.png" width="62px" height="62px" /><div style="position:relative;top:-58px;left:6px;z-index:6;width:50px;height:50px;background: url(../images/blizzard/' + sourceBnetPic + '-90.jpg) '+sourceBnetPicXoff+'px '+sourceBnetPicYoff+'px;" ></div><div style="text-decoration:underline;font-weight:bold;text-align:center;position:relative;top:-30px;">Awards</div></div></td>' +
			'<td style="vertical-align: top; padding-left: 10px !important;width:110px !important;"><div class="sourceNameFont" style="text-overflow: ellipsis; width: 100px !important; overflow: hidden; white-space: nowrap;">' + sourceName + '</div><br/><span>' + sourceGroup + ',<br/><!--' + sourceRank + '--></span></td>' +
			'<td style="vertical-align: top; padding-left: 10px !important;width:100px !important;"><div style="width:100px;"><table><tr><td colspan="2" style="text-decoration:underline;font-weight:bold;text-align:center;">Statistics</td></tr><tr><td colspan="2">&nbsp;</td></tr><tr><td>1v1 Wins:</td><td>&nbsp;&nbsp;' + wins + '</td></tr><tr><td>1v1Losses:</td><td>&nbsp;&nbsp;' + losses + '</td></tr><tr><td>W/L Ratio:</td><td><span style="color:' + WLcolor + '">&nbsp;&nbsp;' + WLratio + '%</span></td></tr><tr><td colspan="2">&nbsp;</td></tr><tr><td colspan="2">&nbsp;</td></tr><tr><td colspan="2" style="text-align:center;text-decoration:underline;">Links</td></tr><tr><td colspan="2">&nbsp;</td></tr><tr><td>SC2 Profile:</td><td>&nbsp;&nbsp;<a href="' + sourceBnet + '" target="_blank">link</a></td></tr><tr><td>Forum:</td><td>&nbsp;&nbsp;<a href="' + sourceuCoz + '" target="_blank">link</a></td></tr>' + adminLoggedIn + '</table></div></td>' +
			'</tr>' +
			'<tr style="vertical-align: top;">' +
			'<td style="vertical-align: top;position:relative;top:-'+ifislogged+'px;"><h3>Awards</h3></br>' + awardsListed + '</td>' +
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
		$("#popup").show();
	});

	/*$("#popupRank").on("click", "#popupRank", function(event)
	{
		//alert("test");
		$(".leagueBorderImage").animate({"margin-left" : "20px"}, 0);
	});*/
	function getParameterByName(name, url) 
	{
	    if (!url) url = window.location.href;
	    name = name.replace(/[\[\]]/g, "\\$&");
	    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
	        results = regex.exec(url);
	    if (!results) return null;
	    if (!results[2]) return '';
	    return decodeURIComponent(results[2].replace(/\+/g, " "));
	}

	$("#closePopup").click(function()
	{
		$("#popup").hide();
	});
	colored = 0;

	$(".rainbow2").click(function()
	{
		$("#rainbowColorTable").toggle();
		$("#altExplain").toggle();
		$(".lazyBlizzard").html("");
		if(colored !== 0)
		{
			$(".viewInfo").css({"color" : "rgba(87, 118, 160, 1.0)"});
			colored = 0;
			return;
		}
		activeE = 0;
		active15 = 0;
		active14 = 0;
		active12 = 0;
		active10 = 0;
		active7 = 0;
		active5 = 0;
		active3 = 0;
		active1 = 0;
		$(".epochTimes").each(function() 
		{
			var newIdToUse = (this.id).replace("_lastGame", "");
			var activity = parseInt($("#" + this.id).html());
			if(activity <= 1)
			{
				activityColor = "#33FF8D"; // green
				if(getParameterByName('method') == "showGroupsW")
						{
							activityColor = "#14a014"; // green
							
						}
				active1++;
				activity = 9999;
			}
			if(activity <= 3)
			{
				activityColor = "#33FFF3"; // green teal
				if(getParameterByName('method') == "showGroupsW")
						{
							
							activityColor = "#14a014"; // yellow
						}
				active3++;
				activity = 9999;
			}
			if(activity <= 5)
			{
				activityColor = "#33A5FF"; // light blue
				if(getParameterByName('method') == "showGroupsW")
						{
							activityColor = "#ff9628"; // orange
						}
				active5++;
				activity = 9999;
			}
			if(activity <= 7)
			{
				activityColor = "#333FFF"; // blue
				if(getParameterByName('method') == "showGroupsW")
						{
							
							activityColor = "#18a0c8"; // lightblue
						}
				active7++;
				activity = 9999;
			}
			if(activity <= 10)
			{
				activityColor = "#8D33FF"; // purple-blue
				if(getParameterByName('method') == "showGroupsW")
						{
							
							activityColor = "#281e96"; // blue

						}
				active10++;
				activity = 9999;
			}
			if(activity <= 12)
			{
				activityColor = "#F333FF"; // pink-purple
				if(getParameterByName('method') == "showGroupsW")
						{
							
							
							activityColor = "#ff6496"; // pink
						}
				active12++;
				activity = 9999;
			}
			if(activity <= 14)
			{
				activityColor = "#FF3333"; // red
				if(getParameterByName('method') == "showGroupsW")
						{
							
							activityColor = "#e31c2d"; // red
						}
				active14++;
				activity = 9999;
			}
			if(activity > 14)
			{
				if(activity < 9999)
				{
					if(getParameterByName('method') == "showGroupsW")
					{
						activityColor = "#981498"; // purple
					}
					else
					{
						activityColor = "#FFFFFF"; // white
					}
					active15++;
				}
				if(activity > 9999)
				{
					var olderIdName = $(this).attr("id");
					var newerIdName = olderIdName.replace(/_lastGame/g, "_lastRealGame");
					var alternativeActivity = $("#" + newerIdName).html();
					var rankEdit = olderIdName.replace(/_lastGame/g, "");
					$("#" + rankEdit).html(($("#" + rankEdit).html()) + "<span class='lazyBlizzard' style='color:orange;'>**</span>");
					if(alternativeActivity <= 1)
					{
						activityColor = "#33FF8D"; // green
						if(getParameterByName('method') == "showGroupsW")
						{
							activityColor = "#14a014"; // green
						}
						active1++;
						alternativeActivity = 9999;
					}
					if(alternativeActivity <= 3)
					{
						activityColor = "#33FFF3"; // green teal
						if(getParameterByName('method') == "showGroupsW")
						{
							activityColor = "#14a014"; // yellow
						}
						active3++;
						alternativeActivity = 9999;
					}
					if(alternativeActivity <= 5)
					{
						activityColor = "#33A5FF"; // light blue
						if(getParameterByName('method') == "showGroupsW")
						{
							activityColor = "#ff9628"; // orange
						}
						active5++;
						alternativeActivity = 9999;
					}
					if(alternativeActivity <= 7)
					{
						activityColor = "#333FFF"; // blue
						if(getParameterByName('method') == "showGroupsW")
						{
							activityColor = "#18a0c8"; // lightblue
						}
						active7++;
						alternativeActivity = 9999;
					}
					if(alternativeActivity <= 10)
					{
						activityColor = "#8D33FF"; // purple-blue
						if(getParameterByName('method') == "showGroupsW")
						{
							activityColor = "#281e96"; // blue
						}
						active10++;
						alternativeActivity = 9999;
					}
					if(alternativeActivity <= 12)
					{
						activityColor = "#F333FF"; // pink-purple
						if(getParameterByName('method') == "showGroupsW")
						{
							activityColor = "#ff6496"; // pink
						}
						active12++;
						alternativeActivity = 9999;
					}
					if(alternativeActivity <= 14)
					{
						activityColor = "#FF3333"; // red
						if(getParameterByName('method') == "showGroupsW")
						{
							activityColor = "#e31c2d"; // red
						}
						active14++;
						alternativeActivity = 9999;
					}
					if(alternativeActivity > 14)
					{
						if(alternativeActivity < 9999)
						{
							if(getParameterByName('method') == "showGroupsW")
							{
								activityColor = "#981498"; // purple
							}
							else
							{
								activityColor = "#FFFFFF"; // white
							}
							active15++;
						}
						if(alternativeActivity > 9999)
						{
							if(getParameterByName('method') == "showGroupsW")
							{
								activityColor = "#981498"; // purple
							}
							else
							{
								activityColor = "#FFFFFF"; // white
							}
							active15++;
						}
					}
				}
			}

			$("#" + newIdToUse).css({"color" : activityColor});

			//var activeEp = ((activeE/($("#totalMemberCount").html())) * 100).toFixed(2);
			//$(".countE").html(activeE + "&nbsp;&nbsp;:&nbsp;&nbsp;" + activeEp + "%");
			
			var active1p = ((active1/($("#totalMemberCount").html())) * 100).toFixed(2);
			$(".count1").html(active1 + "&nbsp;&nbsp;:&nbsp;&nbsp;" + active1p + "%");

			var active3p = ((active3/($("#totalMemberCount").html())) * 100).toFixed(2);
			$(".count3").html(active3 + "&nbsp;&nbsp;:&nbsp;&nbsp;" + active3p + "%");

			var active5p = ((active5/($("#totalMemberCount").html())) * 100).toFixed(2);
			$(".count5").html(active5 + "&nbsp;&nbsp;:&nbsp;&nbsp;" + active5p + "%");

			var active7p = ((active7/($("#totalMemberCount").html())) * 100).toFixed(2);
			$(".count7").html(active7 + "&nbsp;&nbsp;:&nbsp;&nbsp;" + active7p + "%");

			var active10p = ((active10/($("#totalMemberCount").html())) * 100).toFixed(2);
			$(".count10").html(active10 + "&nbsp;&nbsp;:&nbsp;&nbsp;" + active10p + "%");

			var active12p = ((active12/($("#totalMemberCount").html())) * 100).toFixed(2);
			$(".count12").html(active12 + "&nbsp;&nbsp;:&nbsp;&nbsp;" + active12p + "%");

			var active14p = ((active14/($("#totalMemberCount").html())) * 100).toFixed(2);
			$(".count14").html(active14 + "&nbsp;&nbsp;:&nbsp;&nbsp;" + active14p + "%");

			var active15p = ((active15/($("#totalMemberCount").html())) * 100).toFixed(2);
			$(".count15").html(active15 + "&nbsp;&nbsp;:&nbsp;&nbsp;" + active15p + "%");

			colored = 1;
		});
	});
});