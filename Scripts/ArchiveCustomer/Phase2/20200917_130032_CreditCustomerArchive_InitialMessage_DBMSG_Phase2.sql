/*<info serverAlias="DBMSG-bodb_message" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
/*
	Created: 20200917@Helen
	Task: https://nexdev.net/issues/130032
	DB: DBMSG.bodb_message
*/

USE bodb_message
GO

TRUNCATE TABLE CustArchiveMessage
GO
INSERT INTO CustArchiveMessage (StageID, GroupLevelName, Content_en
		, Content_vn, Content_ch, Content_cs, Content_th
		)
VALUES 
-----------------------Stage 1 --------------------------
--- M2, S2, S3
(1,'M2',
N'Dear valued agents, Please be informed that some of your Agents were closed due to inactivity in the past 3 months. If you wish them to continue their business, you can reopen these accounts, otherwise you can take back their given credit. 1 month after being closed, these accounts will be disabled, and you will not be able to recover the given credit from them, which will result in a shortage of your total credit. Please note that disabled accounts will not be restored. Thank you.',
N'Kính gửi quý khách hàng, Xin lưu ý rằng một số Agent của bạn đã bị khoá do không hoạt động trong 3 tháng qua. Nếu bạn muốn họ tiếp tục hoạt động, bạn có thể mở lại các tài khoản này, nếu không bạn có thể lấy lại tín dụng đã cấp cho họ. Sau khi bị đóng 1 tháng, các tài khoản này sẽ bị vô hiệu hóa và bạn sẽ không thể phục hồi khoản tín dụng đã cấp cho chúng, điều này sẽ dẫn đến việc giảm tổng số tín dụng của bạn. Lưu ý rằng tài khoản bị vô hiệu hoá sẽ không thể phục hồi. Trân trọng.',
N'尊敬的代理們, 特此通知，由於您的一些代理已長達近三個月無活躍操作，因此賬號已被關閉。倘若關閉賬號持有者有意繼續進行生意，您可重啟賬號，除此以外也可以取回該賬號的信用額。賬號將在關閉後的一個月被禁用。您將無法從這些賬號取回信用額，這將導致您的信用額度不足。請知悉，禁用後的賬號將無法重啟。謝謝。',
N'尊敬的代理们, 特此通知，由于您的一些代理已长达近三个月无活跃操作，因此账号已被关闭。倘若关闭账号持有者有意继续进行生意，您可重启账号，除此以外也可以取回该账号的信用额。账号将在关闭后的一个月被禁用。您将无法从这些账号取回信用额，这将导致您的信用额度不足。请知悉，禁用后的账号将无法重启。谢谢。',
N'เรียน ลูกค้าที่เคารพ ขอแจ้งให้ทราบว่าเอเจนต์บางส่วนของคุณถูกปิดเนื่องจากไม่มีการใช้งานในช่วง 3 เดือนที่ผ่านมา หากคุณต้องการให้พวกเขาทำธุรกิจต่อ คุณสามารถเปิดบัญชีเหล่านี้อีกครั้ง มิฉะนั้นคุณสามารถนำยอดเครดิตของพวกเขากลับคืนมา หนึ่งเดือนหลังจากถูกปิด บัญชีเหล่านี้จะถูกปิดใช้งานและคุณจะไม่สามารถเรียกคืนเครดิตจากบัญชีเหล่านี้ได้ซึ่งจะทำให้วงเงินเครดิตรวมของคุณไม่เพียงพอ โปรดทราบว่าบัญชีที่ถูกปิดใช้งานไม่สามารถกู้คืนได้ ขอบพระคุณ'),
(1,'S2',
N'Dear valued agents, Please be informed that some of your Masters were closed due to inactivity in the past 3 months. If you wish them to continue their business, you can reopen these accounts, otherwise you can take back their given credit. 1 month after being closed, these accounts will be disabled, and you will not be able to recover the given credit from them, which will result in a shortage of your total credit. Please note that disabled accounts will not be restored. Thank you.',
N'Kính gửi quý khách hàng, Xin lưu ý rằng một số Master của bạn đã bị khoá do không hoạt động trong 3 tháng qua. Nếu bạn muốn họ tiếp tục hoạt động, bạn có thể mở lại các tài khoản này, nếu không bạn có thể lấy lại tín dụng đã cấp cho họ. Sau khi bị đóng 1 tháng, các tài khoản này sẽ bị vô hiệu hóa và bạn sẽ không thể phục hồi khoản tín dụng đã cấp cho chúng, điều này sẽ dẫn đến việc giảm tổng số tín dụng của bạn. Lưu ý rằng tài khoản bị vô hiệu hoá sẽ không thể phục hồi. Trân trọng.',
N'尊敬的代理們, 特此通知，由於您的一些總代理已長達近三個月無活躍操作，因此賬號已被關閉。倘若關閉賬號持有者有意繼續進行生意，您可重啟賬號，除此以外也可以取回該賬號的信用額。賬號將在關閉後的一個月被禁用。您將無法從這些賬號取回信用額，這將導致您的信用額度不足。請知悉，禁用後的賬號將無法重啟。謝謝。',
N'尊敬的代理们, 特此通知，由于您的一些总代理已长达近三个月无活跃操作，因此账号已被关闭。倘若关闭账号持有者有意继续进行生意，您可重启账号，除此以外也可以取回该账号的信用额。账号将在关闭后的一个月被禁用。您将无法从这些账号取回信用额，这将导致您的信用额度不足。请知悉，禁用后的账号将无法重启。谢谢。',
N'เรียน ลูกค้าที่เคารพ ขอแจ้งให้ทราบว่ามาสเตอร์บางส่วนของคุณถูกปิดเนื่องจากไม่มีการใช้งานในช่วง 3 เดือนที่ผ่านมา หากคุณต้องการให้พวกเขาทำธุรกิจต่อ คุณสามารถเปิดบัญชีเหล่านี้อีกครั้ง มิฉะนั้นคุณสามารถนำยอดเครดิตของพวกเขากลับคืนมา หนึ่งเดือนหลังจากถูกปิด บัญชีเหล่านี้จะถูกปิดใช้งานและคุณจะไม่สามารถเรียกคืนเครดิตจากบัญชีเหล่านี้ได้ซึ่งจะทำให้วงเงินเครดิตรวมของคุณไม่เพียงพอ โปรดทราบว่าบัญชีที่ถูกปิดใช้งานไม่สามารถกู้คืนได้ ขอบพระคุณ'),
(1,'S3',
N'Dear valued agents, Please be informed that some of your Agents were closed due to inactivity in the past 3 months. You should consider taking back the given credit from these accounts. 1 month after being closed, these accounts will be disabled, and you will not be able to recover the given credit from them, which will result in a shortage of your total credit. Thank you.',
N'Kính gửi quý khách hàng, Xin lưu ý rằng một số Agent của bạn đã bị khoá do không hoạt động trong 3 tháng qua. Bạn nên xem xét việc lấy lại tín dụng đã cấp cho họ. Sau khi bị đóng 1 tháng, các tài khoản này sẽ bị vô hiệu hóa và bạn sẽ không thể phục hồi khoản tín dụng đã cấp cho chúng, điều này sẽ dẫn đến việc giảm tổng số tín dụng của bạn. Trân trọng.',
N'尊敬的代理們, 特此通知，由於您的一些代理已長達近三個月無活躍操作，因此賬號已被關閉。您可考慮從這些賬戶取回信用額。賬號將在關閉後的一個月被禁用。您將無法從這些賬號取回信用額，這將導致您的信用額度不足。謝謝。',
N'尊敬的代理们, 特此通知，由于您的一些代理已长达近三个月无活跃操作，因此账号已被关闭。您可考虑从这些账户取回信用额。账号将在关闭后的一个月被禁用。您将无法从这些账号取回信用额，这将导致您的信用额度不足。谢谢。',
N'เรียน ลูกค้าที่เคารพ ขอแจ้งให้ทราบว่าเอเจนต์บางส่วนของคุณถูกปิดเนื่องจากไม่มีการใช้งานในช่วง 3 เดือนที่ผ่านมา คุณควรพิจารณานำเครดิตที่ได้รับกลับมาจากบัญชีเหล่านี้ หนึ่งเดือนหลังจากถูกปิด บัญชีเหล่านี้จะถูกปิดใช้งานและคุณจะไม่สามารถเรียกคืนเครดิตจากบัญชีเหล่านี้ได้ซึ่งจะทำให้วงเงินเครดิตรวมของคุณไม่เพียงพอ ขอบพระคุณ'),
-----------------------Stage 2 --------------------------
--- S2, M2, S3
(2,'S2',
N'Dear valued agents, Please be informed that some of your Masters were disabled due to their Member inactivity in the past 4 months. Their credit has been cleared and your given credit has been decreased by the total cleared amounts. Please note that disabled accounts will not be restored. Thank you.',
N'Kính gửi quý khách hàng, Xin lưu ý rằng một số Master của bạn đã bị vô hiệu hoá do Member của họ không hoạt động trong 4 tháng qua. Tín dụng của họ đã bị xoá và tín dụng có thể cấp của bạn đã bị giảm bởi tổng số tín dụng bị xoá này. Lưu ý rằng tài khoản bị vô hiệu hoá sẽ không thể phục hồi. Trân trọng.',
N'尊敬的代理們, 特此通知，您的一些總代理賬號已被禁用，由於會員已長達四個月無活躍操作。總代理賬號的信用額已被清除，而您的信用額度也已減少按照被清除的總金額。請知悉，禁用後的賬號將無法重啟。謝謝。',
N'尊敬的代理们, 特此通知，您的一些总代理账号已被禁用，由于会员已长达四个月无活跃操作。总代理账号的信用额已被清除，而您的信用额度也已减少按照被清除的总金额。请知悉，禁用后的账号将无法重启。谢谢。',
N'เรียน ลูกค้าที่เคารพ ขอแจ้งให้ทราบว่ามาสเตอร์บางส่วนของคุณถูกปิด เนื่องจากสมาชิกไม่มีการใช้งานในช่วง 4 เดือนที่ผ่านมา เครดิตของพวกเขาถูกหักล้างและวงเงินเครดิตของคุณถูกลดลงตามจำนวนเงินทั้งหมดที่เคลียร์ โปรดทราบว่าบัญชีที่ถูกปิดใช้งานไม่สามารถกู้คืนได้ ขอบพระคุณ'),
(2,'M2',
N'Dear valued agents, Please be informed that some of your Agents were disabled due to their Member inactivity in the past 4 months. Their credit has been cleared and your given credit has been decreased by the total cleared amounts. Please note that disabled accounts will not be restored. Thank you.',
N'Kính gửi quý khách hàng, Xin lưu ý rằng một số Agent của bạn đã bị vô hiệu hoá do Member của họ không hoạt động trong 4 tháng qua. Tín dụng của họ đã bị xoá và tín dụng có thể cấp của bạn đã bị giảm bởi tổng số tín dụng bị xoá này. Lưu ý rằng tài khoản bị vô hiệu hoá sẽ không thể phục hồi. Trân trọng.',
N'尊敬的代理們, 特此通知，您的一些代理賬號已被禁用，由於會員已長達四個月無活躍操作。他們的信用已被清除，而您的信用額度也已減少按照被清除的總金額。請知悉，禁用後的賬號將無法重啟。謝謝。',
N'尊敬的代理们, 特此通知，您的一些代理账号已被禁用，由于会员已长达四个月无活跃操作。他们的信用已被清除，而您的信用额度也已减少按照被清除的总金额。请知悉，禁用后的账号将无法重启。谢谢。',
N'เรียน ลูกค้าที่เคารพ ขอแจ้งให้ทราบว่าเอเจนต์บางส่วนของคุณถูกปิด เนื่องจากสมาชิกไม่มีการใช้งานในช่วง 4 เดือนที่ผ่านมา เครดิตของพวกเขาถูกหักล้างและวงเงินเครดิตของคุณถูกลดลงตามจำนวนเงินทั้งหมดที่เคลียร์ โปรดทราบว่าบัญชีที่ถูกปิดใช้งานไม่สามารถกู้คืนได้ ขอบพระคุณ'),
(2,'S3',
N'Dear valued agents, Please be informed that some of your Agents were disabled due to their Member inactivity in the past 4 months. Their credit has been cleared and your given credit has been decreased by the total cleared amounts. Please note that disabled accounts will not be restored. Thank you.',
N'Kính gửi quý khách hàng, Xin lưu ý rằng một số Agent của bạn đã bị vô hiệu hoá do Member của họ không hoạt động trong 4 tháng qua. Tín dụng của họ đã bị xoá và tín dụng có thể cấp của bạn đã bị giảm bởi tổng số tín dụng bị xoá này. Lưu ý rằng tài khoản bị vô hiệu hoá sẽ không thể phục hồi. Trân trọng.',
N'尊敬的代理們, 特此通知，您的一些代理賬號已被禁用，由於會員已長達四個月無活躍操作。他們的信用已被清除，而您的信用額度也已減少按照被清除的總金額。請知悉，禁用後的賬號將無法重啟。謝謝。',
N'尊敬的代理们, 特此通知，您的一些代理账号已被禁用，由于会员已长达四个月无活跃操作。他们的信用已被清除，而您的信用额度也已减少按照被清除的总金额。请知悉，禁用后的账号将无法重启。谢谢。',
N'เรียน ลูกค้าที่เคารพ ขอแจ้งให้ทราบว่าเอเจนต์บางส่วนของคุณถูกปิด เนื่องจากสมาชิกไม่มีการใช้งานในช่วง 4 เดือนที่ผ่านมา เครดิตของพวกเขาถูกหักล้างและวงเงินเครดิตของคุณถูกลดลงตามจำนวนเงินทั้งหมดที่เคลียร์ โปรดทราบว่าบัญชีที่ถูกปิดใช้งานไม่สามารถกู้คืนได้ ขอบพระคุณ'),
-----------------------Stage 3 --------------------------
--- S2, M2
(3,'S2',
N'Dear valued agents, Please be informed that some of your disabled Masters have been inactive for the past 7 months, their balances have been transferred to you. Please note that disabled accounts will not be restored. Thank you.',
N'Kính gửi quý khách hàng, Xin lưu ý rằng vài Master bị vô hiệu hoá của bạn đã không có hoạt động nào trong 7 tháng qua, tín dụng của họ đã được chuyển cho bạn. Lưu ý rằng tài khoản bị vô hiệu hoá sẽ không thể phục hồi. Trân trọng.',
N'尊敬的代理們, 特此通知，您的一些禁用總代理已長達七個月無活躍操作，其余額已轉至您的賬戶。請知悉，禁用的賬戶將無法重啟。謝謝。',
N'尊敬的代理们, 特此通知，您的一些禁用总代理已长达七个月无活跃操作，其余额已转至您的账户。请知悉，禁用的账户将无法重启。谢谢。',
N'เรียน ลูกค้าที่เคารพ ขอแจ้งให้ทราบว่ามาสเตอร์บางส่วนของคุณไม่ได้ใช้งานในช่วง 7 เดือนที่ผ่านมาและยอดเงินของพวกเขาได้ถูกโอนมาให้คุณ โปรดทราบว่าบัญชีที่ถูกปิดใช้งานไม่สามารถกู้คืนได้ ขอบพระคุณ'),
(3,'M2',
N'Dear valued agents, Please be informed that some of your disabled Agents have been inactive for the past 7 months, their balances have been transferred to you. Please note that disabled accounts will not be restored. Thank you.',
N'Kính gửi quý khách hàng, Xin lưu ý rằng vài Agent bị vô hiệu hoá của bạn đã không có hoạt động nào trong 7 tháng qua, tín dụng của họ đã được chuyển cho bạn. Lưu ý rằng tài khoản bị vô hiệu hoá sẽ không thể phục hồi. Trân trọng.',
N'尊敬的代理們, 特此通知，您的一些禁用代理已長達七個月無活躍操作，其余額已轉至您的賬戶。請知悉，禁用的賬戶將無法重啟。謝謝。',
N'尊敬的代理们, 特此通知，您的一些禁用代理已长达七个月无活跃操作，其余额已转至您的账户。请知悉，禁用的账户将无法重启。谢谢。',
N'เรียน ลูกค้าที่เคารพ ขอแจ้งให้ทราบว่าเอเจนต์บางส่วนของคุณไม่ได้ใช้งานในช่วง 7 เดือนที่ผ่านมาและยอดเงินของพวกเขาได้ถูกโอนมาให้คุณ โปรดทราบว่าบัญชีที่ถูกปิดใช้งานไม่สามารถกู้คืนได้ ขอบพระคุณ')
