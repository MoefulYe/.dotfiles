rec {
  byRegion = {
    "hk" = [
      "香港"
      "九龙"
      "新界"
      "HK"
      "Hong Kong"
    ];
    "tw" = [
      "台湾"
      "台北"
      "新北"
      "高雄"
      "TW"
      "Taiwan"
      "Tai wan"
    ];
    "jp" = [
      "日本"
      "东京"
      "大阪"
      "京都"
      "名古屋"
      "埼玉"
      "JP"
      "Japan"
    ];
    "kr" = [
      "韩国"
      "韓國"
      "首尔"
      "釜山"
      "KR"
      "Korea"
    ];
    "sg" = [
      "新加坡"
      "狮城"
      "SG"
      "Singapore"
    ];
    "us" = [
      "美国"
      "波特兰"
      "达拉斯"
      "俄勒冈"
      "凤凰城"
      "费利蒙"
      "硅谷"
      "拉斯维加斯"
      "洛杉矶"
      "圣何塞"
      "圣克拉拉"
      "西雅图"
      "芝加哥"
      "US"
      "United States"
      "America"
    ];
    "uk" = [
      "英国"
      "伦敦"
      "曼彻斯特"
      "UK"
      "United Kingdom"
      "Britain"
    ];
    "fr" = [
      "法国"
      "巴黎"
      "马赛"
      "FR"
      "France"
    ];
    "de" = [
      "德国"
      "柏林"
      "法兰克福"
      "慕尼黑"
      "DE"
      "Germany"
    ];
    "ca" = [
      "加拿大"
      "多伦多"
      "温哥华"
      "蒙特利尔"
      "CA"
      "Canada"
    ];
    "in" = [
      "印度"
      "孟买"
      "班加罗尔"
      "德里"
      "IN"
      "India"
    ];
  };
  toRegionMatchReg = keywords: "(?i)${builtins.concatStringsSep "|" keywords}";
  regionMatchRegs = builtins.mapAttrs (_: keywords: toRegionMatchReg keywords) byRegion;
  otherRegionMatchReg =
    let
      allKeywords = builtins.concatStringsSep "|" (builtins.concatLists (builtins.attrValues byRegion));
    in
    "(?i)^(?!.*(?:${allKeywords})).*";
  regions = builtins.attrNames byRegion;
}
