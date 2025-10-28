
CREATE FUNCTION [dbo].[f_GetBalanceType]
(
    @bettype int
)
    RETURNS tinyint
/*
Params explanation
        type = 1 - Sports
        type = 3 - Casino
        type = 4 - Others
- 20150910 @Joychen: Add GetbalType
- 20151218 @Victor:change super live to Type 4 (Others)
- 20160122 @Cooper: add one casino bettype 2101 ~ 2399
- 20160511 @BrianYang : add VB casino bettype 4001 ~ 7999
- 20160902 @Sylvia : add N7 bettype 2501 ~ 2699 to Type 4 (Others)
- 20161012 @Joy : add PH all in one 401~447 to Type 1
- 20161207 @Joy : add GG 1010~1019  to Type 4
- 20170517 @Sylvia : add BAIO 601~617 to Type 1
- 20170517 @Sylvia : add Lucky3 1600 to Type 4
- 20170706 @Joy : add Keno Lottery 1021->1049 to Type 4
- 20170719 @Joy : add Betradar Virtual Sports 2700->2899 to Type 4
- 20170728 @Joy : add Casino-tablet Sports 2901 --> 2999 to Type 3
- 20171019 @Joy : add Bullfighting 1004 to Type 4
- 20180528 @James : add Keno new game 1517,1519,1520,1521,1522,1524
- 20180704 @Sylvia : add Poker Games 1401 ~ 1499 to Type 3
- 20180830 @Alfie : add GD 1704, 1705 to Type 3
- 20181220 @James : add Happy5 8101~8105 to Type 3
- 20190304 @Sylvia : add bettype 1901-1999, Integrate Video Poker games with Card Club, to Type 3
- 20190304 @Sylvia : add BetBuilder 38 to Type 1
- 20190820 @Cooper : add Keno new games 1525 , 1526 in [type = 4 - Others]
- 20200330 @James : add Sexy Casino 3101~3105 to Type 3
- 20200331 @sobi : add saba club 1611 ~ 1614, indo4d 5001~5007
- 20200415 @Victor : add TableGame 4901~4999
- 20200428 @Aaron : add GT Live 3201~3299
--20200505 @James : add SBO 5500~5599,ION 5601~5699 to Type3
--20200506 @Sylvia: add bbin casino 3300
--20200526 @James : add SA Gaming 3001~3099 to Type3
--20200714 @Yolanda : modify Lottery 1021-1099 rang and Keno,Lottery to Type3
--20200908 @Victor : add color ball 91 to Type 4
--20200929 @Victor : add Joker Gaming 6401~6699 to Type 3
--20200930 @Cooper : add PG Soft 6001 ~ 6299 to type 3
--20201029 @Victor : add WM LiveCasino 3401 ~ 3499 to type 3
--20201117 @Aaron : add Leap Gaming 5301 ~ 5399 to Type 4
--20201210 @EricFu : add GDG 5701 ~ 5799 to type 3 | BG Live Casino 3501 - 3599
--20201210 @Yolanda : add MaxGame 5401~5499, ACE333 6801~7000, Habanero 7001~7300, CreativeGaming 7301~7600 to type 3
--20201225 @EricFu : add LinkedGames 3601 ~ 3610 to Type 4
--20210305 @FannyChen : add Sports Lottery 3611 ~ 3620 to type 3 | PP Live Casino 3701 ~ 3799 to type 3
--20210512 @EricFu : add Vgaming 3801 ~ 3899 | Advantplay 7701-7799 to Type 3
--20210528 @FannyChen : add AdvantplayMini 7801-7899 to Type 3
--20210928 @Victor : add Bitcoin 7901-7999 to Type 4
--20220103 @Chloe : add FGG 8201-8209 & TopGaming 8301-8399 to Type 3
--20220411 @EricFu : add extra PPrng 6701 ~ 7000 | VB 5800-5999 to Type 3 | remove Ace333 settings
--20220819 @EricFu(DBTrans/SiteDB) : add MG 8400 ~ 8499 | SEAL Entertainment 8900 ~ 8999
--20230309 @ChloeLee(DBTrans/SiteDB) : add JiLi 5100-5299
--20230502 @ChloeLee(DBTrans/SiteDB) : add YeeBet 3151-3200 to type 3
--20240711 @ChloeLee(DBTrans/SiteDB) : add UU SLOTS | Live22 | WorldEntertainment | NextSpin | SABA xD | FastSpin | FA CHAI | GPI RNG Casino | GPI Live Casino to Type 3, Virtual Cock Fighting | Virtually Sports to Type 4
--20250325 @ElsieHsu(DBTrans/SiteDB) : add HotDog 11900 ~ 11999 | AskMeSlot 15000 ~ 15199 | FunkyGames 15200 ~ 15399 to Type 3
--20250416 @TandyTien(DBTrans/SiteDB) : add PlayTechLive 15600 ~ 15799 | MicroGamingLive 13900 ~ 13999 to Type 3
--20250508 @JerryLin(DBTrans/SiteDB) : add RichGaming 15800 ~ 15899 to Type 3
--20250617 @ElsieHsu(DBTrans/SiteDB) : add WCasino 12000 ~ 12099 | ClotPlay 16100 ~ 16199 | AIGaming 16200 ~ 16299 to Type 3
--20250826 @ElsieHsu(DBTrans/SiteDB) : add SmartSoftGaming 12150 ~ 12249 to Type 3
*/
AS
BEGIN
    Declare @type tinyint

    IF @bettype in (38)
        or (@bettype between 1 and 30)
        or (@bettype between 121 and 221)
        or (@bettype between 301 and 304) -- Myanmar Odds - Soccer Credit only, Deadball only
        or (@bettype between 401 and 447) -- PH All in one - Soccer(Deadball)
        or (@bettype between 601 and 617) -- Basketball All in one(both)
        or (@bettype between 901 and 910) -- Bet trade: [901 -910]
        or (@bettype between 1301 and 1334) -- Sporting Solution of Tennis
        SET @type = 1
    ELSE IF   @bettype in (71,72,3300)
        or (@bettype between 1021 and 1099) -- lottery
        or (@bettype between 1101 and 1199) -- live casino
        or (@bettype between 1401 and 1499) -- Poker Games
        or (@bettype between 1501 and 1599) -- keno
        or (@bettype between 1611 and 1699) -- sabaclub
        or (@bettype between 1701 and 1799) -- Gold Deluxe
        or (@bettype between 1801 and 1899) -- AG Casino
        or (@bettype between 1901 and 1999) -- cardclub
        or (@bettype between 2001 and 2099) -- Microgame
        or (@bettype between 2101 and 2499) -- 2101-2199 RNG Casino / 2201-2299 RnG Mini Game / 2301-2399 RNG Mobile Casino / 2401-2499 Allbet-Live Casino
        or (@bettype between 2901 and 2999) -- RNG - Tablet Casino
        or (@bettype between 3001 and 3099) -- SA Gaming
        or (@bettype between 3101 and 3199) -- sexy gaming
        or (@bettype between 3201 and 3299) -- GT Live
        or (@bettype between 3401 and 3499) -- WM Live Casino
        or (@bettype between 3501 and 3599) -- BG Live Casino
        or (@bettype between 3611 and 3620) -- Sports Lottery
        or (@bettype between 3701 and 3799) -- PP Live Casino
        or (@bettype between 3801 and 3899) -- Vgaming
        or (@bettype between 4001 and 4099) -- Macau Games
        or (@bettype between 4101 and 4300) -- PP
        or (@bettype between 4301 and 4600) -- SG
        or (@bettype between 4601 and 4900) -- Virtual Games
        or (@bettype between 4901 and 4999) -- Table Game
        or (@bettype between 5401 and 5499) -- MaxGame
        or (@bettype between 5500 and 5599) -- SBO
        or (@bettype between 5601 and 5699) -- ION
        or (@bettype between 5701 and 5799) -- GDG
        or (@bettype between 5800 and 5999) -- Extra Macau Games
        or (@bettype between 6001 and 6299) -- PG Soft
        or (@bettype between 6401 and 6699) -- Joker Gaming
        or (@bettype between 6701 and 7000) -- Extra PP
        or (@bettype between 7001 and 7300) -- Habanero
        or (@bettype between 7301 and 7600) -- CreativeGaming
        or (@bettype between 7701 and 7799) -- Advantplay
        or (@bettype between 7801 and 7899) -- AdvantplayMini
        or (@bettype between 8201 and 8209) -- FGG
        or (@bettype between 8301 and 8399) -- TopGaming
        or (@bettype between 8400 and 8699) -- MG
        or (@bettype between 8900 and 8999) -- SEAL Entertainment
        or (@bettype between 5100 and 5299) -- JiLi
        or (@bettype between 3151 and 3200) -- YeeBet
        or (@bettype between 10000 and 10299) -- UU SLOTS
        or (@bettype between 7601 and 7700) -- Live22
        or (@bettype between 10300 and 10399) -- WorldEntertainment
        or (@bettype between 10450 and 10750) -- NextSpin
        or (@bettype between 10801 and 11000) -- SABA xD
        or (@bettype between 11100 and 11299) -- FastSpin
        or (@bettype between 11300 and 11399) -- FA CHAI
        or (@bettype between 11400 and 11499) -- GPI RNG Casino
        or (@bettype between 11500 and 11549) -- GPI Live Casino
        or (@bettype between 11900 and 11999) -- HotDog
        or (@bettype between 15000 and 15199) -- AskMeSlot
        or (@bettype between 15200 and 15399) -- FunkyGames
        or (@bettype between 15600 and 15799) -- PlayTechLive
        or (@bettype between 13900 and 13999) -- MicroGamingLive
        or (@bettype between 15800 and 15899) -- RichGaming
        or (@bettype between 12000 and 12099) -- WCasino
        or (@bettype between 16100 and 16199) -- ClotPlay
        or (@bettype between 16200 and 16299) -- AIGaming
        or (@bettype between 12150 and 12249) -- SmartSoftGaming
        SET @type = 3
    ELSE IF   @bettype in (31,32,33,41,42,43,73,1003,1004,1600)
        or (@bettype between 81 and 91) -- Number Game
        or (@bettype between 801 and 806) -- SuperLive
        or (@bettype between 1010 and 1020) -- globalgaming
        or (@bettype between 1201 and 1299) -- Virtual Soccer (1201-1299 for Virtual Sport)
        or (@bettype between 2501 and 2699)
        or (@bettype between 2700 and 2899) -- Betradar virtual Soccer
        or (@bettype between 3601 and 3610) -- LinkedGames
        or (@bettype between 5001 and 5099) -- indo4d
        or (@bettype between 5301 and 5399) -- Leap Gaming
        or (@bettype between 7901 and 7999) -- Bitcoin
        or (@bettype between 8101 and 8120) -- 8101-8120 for Happy 5
        or (@bettype between 18000 and 18006) -- Colossus Bet
        or (@bettype between 10400 and 10449) -- Virtual Cock Fighting(EdgeGaming)
        or (@bettype between 11050 and 11099) -- Virtually Sports
        SET @type = 4
    ELSE      SET @type = 1

    RETURN @type

END

