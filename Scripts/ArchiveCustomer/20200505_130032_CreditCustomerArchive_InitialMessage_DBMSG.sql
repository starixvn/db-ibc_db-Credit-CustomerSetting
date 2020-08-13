/*
	Created: 20200505@Helen
	Task: https://nexdev.net/issues/130032
	DB: DBMSG.bodb_message
*/

USE bodb_message
GO
INSERT INTO CustArchiveMessage (StageID, GroupLevelName, Content_en
		, Content_vn, Content_ch, Content_cs, Content_th
		)
VALUES 
-----------------------Stage 1 --------------------------
--- S1, S2, S3
(1, 'S1'
	,N'Dear valued agents,<br />
<br />
Please be informed that some of your Agents were closed due to inactivity in the past 3 months. You should consider taking back the given credit from these accounts.<br />
1 month after being closed, these accounts will be disabled, and you will not be able to recover the given credit from them, which will result in a shortage of your total credit.<br />
<br />
Thank you.'

	,N'Kính gửi quý khách hàng,<br />
<br />
Xin lưu ý rằng một số Agent của bạn đã bị khoá do không hoạt động trong 3 tháng qua. Bạn nên xem xét việc lấy lại tín dụng đã cấp cho họ.<br />
Sau khi bị đóng 1 tháng, các tài khoản này sẽ bị vô hiệu hóa và bạn sẽ không thể phục hồi khoản tín dụng đã cấp cho chúng, điều này sẽ dẫn đến việc giảm tổng số tín dụng của bạn.<br />
<br />
Trân trọng.'

	,N'尊敬的代理們,<br />
<br />
特此通知，由於您的一些代理已長達近三個月無活躍操作，因此賬號已被關閉。您可考慮從這些賬戶取回信用額。<br />
賬號將在關閉後的一個月被禁用。您將無法從這些賬號取回信用額，這將導致您的信用額度不足。<br />
<br />
謝謝。'

	,N'尊敬的代理们,<br />
<br />
特此通知，由于您的一些代理已长达近三个月无活跃操作，因此账号已被关闭。您可考虑从这些账户取回信用额。<br />
账号将在关闭后的一个月被禁用。您将无法从这些账号取回信用额，这将导致您的信用额度不足。<br />
<br />
谢谢。'

	,N'เรียน ลูกค้าที่เคารพ<br />
<br />
ขอแจ้งให้ทราบว่าเอเจนต์บางส่วนของคุณถูกปิดเนื่องจากไม่มีการใช้งานในช่วง 3 เดือนที่ผ่านมา คุณควรพิจารณานำเครดิตที่ได้รับกลับมาจากบัญชีเหล่านี้<br />
หนึ่งเดือนหลังจากถูกปิด บัญชีเหล่านี้จะถูกปิดใช้งานและคุณจะไม่สามารถเรียกคืนเครดิตจากบัญชีเหล่านี้ได้ซึ่งจะทำให้วงเงินเครดิตรวมของคุณไม่เพียงพอ<br />
<br />
ขอบพระคุณ'
)

,(1, 'S2'
	,N'Dear valued agents,<br />
<br />
Please be informed that some of your Agents were closed due to inactivity in the past 3 months. You should consider taking back the given credit from these accounts.<br />
1 month after being closed, these accounts will be disabled, and you will not be able to recover the given credit from them, which will result in a shortage of your total credit.<br />
<br />
Thank you.'

	,N'Kính gửi quý khách hàng,<br />
<br />
Xin lưu ý rằng một số Agent của bạn đã bị khoá do không hoạt động trong 3 tháng qua. Bạn nên xem xét việc lấy lại tín dụng đã cấp cho họ.<br />
Sau khi bị đóng 1 tháng, các tài khoản này sẽ bị vô hiệu hóa và bạn sẽ không thể phục hồi khoản tín dụng đã cấp cho chúng, điều này sẽ dẫn đến việc giảm tổng số tín dụng của bạn.<br />
<br />
Trân trọng.'

	,N'尊敬的代理們,<br />
<br />
特此通知，由於您的一些代理已長達近三個月無活躍操作，因此賬號已被關閉。您可考慮從這些賬戶取回信用額。<br />
賬號將在關閉後的一個月被禁用。您將無法從這些賬號取回信用額，這將導致您的信用額度不足。<br />
<br />
謝謝。'

	,N'尊敬的代理们,<br />
<br />
特此通知，由于您的一些代理已长达近三个月无活跃操作，因此账号已被关闭。您可考虑从这些账户取回信用额。<br />
账号将在关闭后的一个月被禁用。您将无法从这些账号取回信用额，这将导致您的信用额度不足。<br />
<br />
谢谢。'

	,N'เรียน ลูกค้าที่เคารพ<br />
<br />
ขอแจ้งให้ทราบว่าเอเจนต์บางส่วนของคุณถูกปิดเนื่องจากไม่มีการใช้งานในช่วง 3 เดือนที่ผ่านมา คุณควรพิจารณานำเครดิตที่ได้รับกลับมาจากบัญชีเหล่านี้<br />
หนึ่งเดือนหลังจากถูกปิด บัญชีเหล่านี้จะถูกปิดใช้งานและคุณจะไม่สามารถเรียกคืนเครดิตจากบัญชีเหล่านี้ได้ซึ่งจะทำให้วงเงินเครดิตรวมของคุณไม่เพียงพอ<br />
<br />
ขอบพระคุณ'
)
,(1, 'S3'
	,N'Dear valued agents,<br />
<br />
Please be informed that some of your Agents were closed due to inactivity in the past 3 months. You should consider taking back the given credit from these accounts.<br />
1 month after being closed, these accounts will be disabled, and you will not be able to recover the given credit from them, which will result in a shortage of your total credit.<br />
<br />
Thank you.'

	,N'Kính gửi quý khách hàng,<br />
<br />
Xin lưu ý rằng một số Agent của bạn đã bị khoá do không hoạt động trong 3 tháng qua. Bạn nên xem xét việc lấy lại tín dụng đã cấp cho họ.<br />
Sau khi bị đóng 1 tháng, các tài khoản này sẽ bị vô hiệu hóa và bạn sẽ không thể phục hồi khoản tín dụng đã cấp cho chúng, điều này sẽ dẫn đến việc giảm tổng số tín dụng của bạn.<br />
<br />
Trân trọng.'

	,N'尊敬的代理們,<br />
<br />
特此通知，由於您的一些代理已長達近三個月無活躍操作，因此賬號已被關閉。您可考慮從這些賬戶取回信用額。<br />
賬號將在關閉後的一個月被禁用。您將無法從這些賬號取回信用額，這將導致您的信用額度不足。<br />
<br />
謝謝。'

	,N'尊敬的代理们,<br />
<br />
特此通知，由于您的一些代理已长达近三个月无活跃操作，因此账号已被关闭。您可考虑从这些账户取回信用额。<br />
账号将在关闭后的一个月被禁用。您将无法从这些账号取回信用额，这将导致您的信用额度不足。<br />
<br />
谢谢。'

	,N'เรียน ลูกค้าที่เคารพ<br />
<br />
ขอแจ้งให้ทราบว่าเอเจนต์บางส่วนของคุณถูกปิดเนื่องจากไม่มีการใช้งานในช่วง 3 เดือนที่ผ่านมา คุณควรพิจารณานำเครดิตที่ได้รับกลับมาจากบัญชีเหล่านี้<br />
หนึ่งเดือนหลังจากถูกปิด บัญชีเหล่านี้จะถูกปิดใช้งานและคุณจะไม่สามารถเรียกคืนเครดิตจากบัญชีเหล่านี้ได้ซึ่งจะทำให้วงเงินเครดิตรวมของคุณไม่เพียงพอ<br />
<br />
ขอบพระคุณ'
)
--- M1, M2
,(1, 'M1'
	,N'Dear valued agents,<br />
<br />
Please be informed that some of your Agents were closed due to inactivity in the past 3 months. If you wish them to continue their business, you can reopen these accounts, otherwise you can take back their given credit.<br />
<br />
1 month after being closed, these accounts will be disabled, and you will not be able to recover the given credit from them, which will result in a shortage of your total credit.<br />
<br />
Please note that disabled accounts will not be restored.<br />
<br />
Thank you.'

	,N'Kính gửi quý khách hàng,<br />
<br />
Xin lưu ý rằng một số Agent của bạn đã bị khoá do không hoạt động trong 3 tháng qua. Nếu bạn muốn họ tiếp tục hoạt động, bạn có thể mở lại các tài khoản này, nếu không bạn có thể lấy lại tín dụng đã cấp cho họ.<br />
<br />
Sau khi bị đóng 1 tháng, các tài khoản này sẽ bị vô hiệu hóa và bạn sẽ không thể phục hồi khoản tín dụng đã cấp cho chúng, điều này sẽ dẫn đến việc giảm tổng số tín dụng của bạn.<br />
<br />
Lưu ý rằng tài khoản bị vô hiệu hoá sẽ không thể phục hồi.<br />
<br />
Trân trọng.'

	,N'尊敬的代理們,<br />
<br />
特此通知，由於您的一些代理已長達近三個月無活躍操作，因此賬號已被關閉。倘若關閉賬號持有者有意繼續進行生意，您可重啟賬號，除此以外也可以取回該賬號的信用額。<br />
<br />
賬號將在關閉後的一個月被禁用。您將無法從這些賬號取回信用額，這將導致您的信用額度不足。<br />
<br />
請知悉，禁用後的賬號將無法重啟。<br />
<br />
謝謝。'

	,N'尊敬的代理们,<br />
<br />
特此通知，由于您的一些代理已长达近三个月无活跃操作，因此账号已被关闭。倘若关闭账号持有者有意继续进行生意，您可重启账号，除此以外也可以取回该账号的信用额。<br />
<br />
账号将在关闭后的一个月被禁用。您将无法从这些账号取回信用额，这将导致您的信用额度不足。<br />
<br />
请知悉，禁用后的账号将无法重启。<br />
<br />
谢谢。'

	,N'เรียน ลูกค้าที่เคารพ<br />
<br />
ขอแจ้งให้ทราบว่าเอเจนต์บางส่วนของคุณถูกปิดเนื่องจากไม่มีการใช้งานในช่วง 3 เดือนที่ผ่านมา หากคุณต้องการให้พวกเขาทำธุรกิจต่อ คุณสามารถเปิดบัญชีเหล่านี้อีกครั้ง มิฉะนั้นคุณสามารถนำยอดเครดิตของพวกเขากลับคืนมา<br />
<br />
หนึ่งเดือนหลังจากถูกปิด บัญชีเหล่านี้จะถูกปิดใช้งานและคุณจะไม่สามารถเรียกคืนเครดิตจากบัญชีเหล่านี้ได้ซึ่งจะทำให้วงเงินเครดิตรวมของคุณไม่เพียงพอ<br />
<br />
โปรดทราบว่าบัญชีที่ถูกปิดใช้งานไม่สามารถกู้คืนได้<br />
<br />
ขอบพระคุณ'
)

,(1, 'M2'
	,N'Dear valued agents,<br />
<br />
Please be informed that some of your Agents were closed due to inactivity in the past 3 months. If you wish them to continue their business, you can reopen these accounts, otherwise you can take back their given credit.<br />
<br />
1 month after being closed, these accounts will be disabled, and you will not be able to recover the given credit from them, which will result in a shortage of your total credit.<br />
<br />
Please note that disabled accounts will not be restored.<br />
<br />
Thank you.'

	,N'Kính gửi quý khách hàng,<br />
<br />
Xin lưu ý rằng một số Agent của bạn đã bị khoá do không hoạt động trong 3 tháng qua. Nếu bạn muốn họ tiếp tục hoạt động, bạn có thể mở lại các tài khoản này, nếu không bạn có thể lấy lại tín dụng đã cấp cho họ.<br />
<br />
Sau khi bị đóng 1 tháng, các tài khoản này sẽ bị vô hiệu hóa và bạn sẽ không thể phục hồi khoản tín dụng đã cấp cho chúng, điều này sẽ dẫn đến việc giảm tổng số tín dụng của bạn.<br />
<br />
Lưu ý rằng tài khoản bị vô hiệu hoá sẽ không thể phục hồi.<br />
<br />
Trân trọng.'

	,N'尊敬的代理們,<br />
<br />
特此通知，由於您的一些代理已長達近三個月無活躍操作，因此賬號已被關閉。倘若關閉賬號持有者有意繼續進行生意，您可重啟賬號，除此以外也可以取回該賬號的信用額。<br />
<br />
賬號將在關閉後的一個月被禁用。您將無法從這些賬號取回信用額，這將導致您的信用額度不足。<br />
<br />
請知悉，禁用後的賬號將無法重啟。<br />
<br />
謝謝。'

	,N'尊敬的代理们,<br />
<br />
特此通知，由于您的一些代理已长达近三个月无活跃操作，因此账号已被关闭。倘若关闭账号持有者有意继续进行生意，您可重启账号，除此以外也可以取回该账号的信用额。<br />
<br />
账号将在关闭后的一个月被禁用。您将无法从这些账号取回信用额，这将导致您的信用额度不足。<br />
<br />
请知悉，禁用后的账号将无法重启。<br />
<br />
谢谢。'

	,N'เรียน ลูกค้าที่เคารพ<br />
<br />
ขอแจ้งให้ทราบว่าเอเจนต์บางส่วนของคุณถูกปิดเนื่องจากไม่มีการใช้งานในช่วง 3 เดือนที่ผ่านมา หากคุณต้องการให้พวกเขาทำธุรกิจต่อ คุณสามารถเปิดบัญชีเหล่านี้อีกครั้ง มิฉะนั้นคุณสามารถนำยอดเครดิตของพวกเขากลับคืนมา<br />
<br />
หนึ่งเดือนหลังจากถูกปิด บัญชีเหล่านี้จะถูกปิดใช้งานและคุณจะไม่สามารถเรียกคืนเครดิตจากบัญชีเหล่านี้ได้ซึ่งจะทำให้วงเงินเครดิตรวมของคุณไม่เพียงพอ<br />
<br />
โปรดทราบว่าบัญชีที่ถูกปิดใช้งานไม่สามารถกู้คืนได้<br />
<br />
ขอบพระคุณ'
)
-----------------------Stage 2 --------------------------
-- S1,S2,S3
,(2, 'S1'
	,N'Dear valued agents,<br />
Please be informed that some of your Agents were disabled due to their Member inactivity in the past 4 months. Their credit has been cleared and your given credit has been decreased by the total cleared amounts. Please note that disabled accounts will not be restored.<br />
Thank you.'

	,N'Kính gửi quý khách hàng,<br />
Xin lưu ý rằng một số Agent của bạn đã bị vô hiệu hoá do Member của họ không hoạt động trong 4 tháng qua. Tín dụng của họ đã bị xoá và tín dụng có thể cấp của bạn đã bị giảm bởi tổng số tín dụng bị xoá này. Lưu ý rằng tài khoản bị vô hiệu hoá sẽ không thể phục hồi.<br />
Trân trọng.'

	,N'尊敬的代理們,<br />
特此通知，您的一些代理賬號已被禁用，由於會員已長達四個月無活躍操作。他們的信用已被清除，而您的信用額度也已減少按照被清除的總金額。請知悉，禁用後的賬號將無法重啟。<br />
謝謝。'

	,N'尊敬的代理们,<br />
特此通知，您的一些代理账号已被禁用，由于会员已长达四个月无活跃操作。他们的信用已被清除，而您的信用额度也已减少按照被清除的总金额。请知悉，禁用后的账号将无法重启。<br />
谢谢。'
	
	,N'เรียน ลูกค้าที่เคารพ<br />
ขอแจ้งให้ทราบว่าเอเจนต์บางส่วนของคุณถูกปิด เนื่องจากสมาชิกไม่มีการใช้งานในช่วง 4 เดือนที่ผ่านมา เครดิตของพวกเขาถูกหักล้างและวงเงินเครดิตของคุณถูกลดลงตามจำนวนเงินทั้งหมดที่เคลียร์ โปรดทราบว่าบัญชีที่ถูกปิดใช้งานไม่สามารถกู้คืนได้<br />
ขอบพระคุณ'
)
,(2, 'S2'
	,N'Dear valued agents,<br />
Please be informed that some of your Agents were disabled due to their Member inactivity in the past 4 months. Their credit has been cleared and your given credit has been decreased by the total cleared amounts. Please note that disabled accounts will not be restored.<br />
Thank you.'

	,N'Kính gửi quý khách hàng,<br />
Xin lưu ý rằng một số Agent của bạn đã bị vô hiệu hoá do Member của họ không hoạt động trong 4 tháng qua. Tín dụng của họ đã bị xoá và tín dụng có thể cấp của bạn đã bị giảm bởi tổng số tín dụng bị xoá này. Lưu ý rằng tài khoản bị vô hiệu hoá sẽ không thể phục hồi.<br />
Trân trọng.'

	,N'尊敬的代理們,<br />
特此通知，您的一些代理賬號已被禁用，由於會員已長達四個月無活躍操作。他們的信用已被清除，而您的信用額度也已減少按照被清除的總金額。請知悉，禁用後的賬號將無法重啟。<br />
謝謝。'

	,N'尊敬的代理们,<br />
特此通知，您的一些代理账号已被禁用，由于会员已长达四个月无活跃操作。他们的信用已被清除，而您的信用额度也已减少按照被清除的总金额。请知悉，禁用后的账号将无法重启。<br />
谢谢。'
	
	,N'เรียน ลูกค้าที่เคารพ<br />
ขอแจ้งให้ทราบว่าเอเจนต์บางส่วนของคุณถูกปิด เนื่องจากสมาชิกไม่มีการใช้งานในช่วง 4 เดือนที่ผ่านมา เครดิตของพวกเขาถูกหักล้างและวงเงินเครดิตของคุณถูกลดลงตามจำนวนเงินทั้งหมดที่เคลียร์ โปรดทราบว่าบัญชีที่ถูกปิดใช้งานไม่สามารถกู้คืนได้<br />
ขอบพระคุณ'
)
,(2, 'S3'
	,N'Dear valued agents,<br />
Please be informed that some of your Agents were disabled due to their Member inactivity in the past 4 months. Their credit has been cleared and your given credit has been decreased by the total cleared amounts. Please note that disabled accounts will not be restored.<br />
Thank you.'

	,N'Kính gửi quý khách hàng,<br />
Xin lưu ý rằng một số Agent của bạn đã bị vô hiệu hoá do Member của họ không hoạt động trong 4 tháng qua. Tín dụng của họ đã bị xoá và tín dụng có thể cấp của bạn đã bị giảm bởi tổng số tín dụng bị xoá này. Lưu ý rằng tài khoản bị vô hiệu hoá sẽ không thể phục hồi.<br />
Trân trọng.'

	,N'尊敬的代理們,<br />
特此通知，您的一些代理賬號已被禁用，由於會員已長達四個月無活躍操作。他們的信用已被清除，而您的信用額度也已減少按照被清除的總金額。請知悉，禁用後的賬號將無法重啟。<br />
謝謝。'

	,N'尊敬的代理们,<br />
特此通知，您的一些代理账号已被禁用，由于会员已长达四个月无活跃操作。他们的信用已被清除，而您的信用额度也已减少按照被清除的总金额。请知悉，禁用后的账号将无法重启。<br />
谢谢。'
	
	,N'เรียน ลูกค้าที่เคารพ<br />
ขอแจ้งให้ทราบว่าเอเจนต์บางส่วนของคุณถูกปิด เนื่องจากสมาชิกไม่มีการใช้งานในช่วง 4 เดือนที่ผ่านมา เครดิตของพวกเขาถูกหักล้างและวงเงินเครดิตของคุณถูกลดลงตามจำนวนเงินทั้งหมดที่เคลียร์ โปรดทราบว่าบัญชีที่ถูกปิดใช้งานไม่สามารถกู้คืนได้<br />
ขอบพระคุณ'
)

-- M1, M2
,(2, 'M1'
	,N'Dear valued agents,<br />
Please be informed that some of your Agents were disabled due to their Member inactivity in the past 4 months. Their credit has been cleared and your given credit has been decreased by the total cleared amounts. Please note that disabled accounts will not be restored.<br />
Thank you.'

	,N'Kính gửi quý khách hàng,<br />
Xin lưu ý rằng một số Agent của bạn đã bị vô hiệu hoá do Member của họ không hoạt động trong 4 tháng qua. Tín dụng của họ đã bị xoá và tín dụng có thể cấp của bạn đã bị giảm bởi tổng số tín dụng bị xoá này. Lưu ý rằng tài khoản bị vô hiệu hoá sẽ không thể phục hồi.<br />
Trân trọng.'

	,N'尊敬的代理們,<br />
特此通知，您的一些代理賬號已被禁用，由於會員已長達四個月無活躍操作。他們的信用已被清除，而您的信用額度也已減少按照被清除的總金額。請知悉，禁用後的賬號將無法重啟。<br />
謝謝。'

	,N'尊敬的代理们,<br />
特此通知，您的一些代理账号已被禁用，由于会员已长达四个月无活跃操作。他们的信用已被清除，而您的信用额度也已减少按照被清除的总金额。请知悉，禁用后的账号将无法重启。<br />
谢谢。'
	
	,N'เรียน ลูกค้าที่เคารพ<br />
ขอแจ้งให้ทราบว่าเอเจนต์บางส่วนของคุณถูกปิด เนื่องจากสมาชิกไม่มีการใช้งานในช่วง 4 เดือนที่ผ่านมา เครดิตของพวกเขาถูกหักล้างและวงเงินเครดิตของคุณถูกลดลงตามจำนวนเงินทั้งหมดที่เคลียร์ โปรดทราบว่าบัญชีที่ถูกปิดใช้งานไม่สามารถกู้คืนได้<br />
ขอบพระคุณ'
)
,(2, 'M2'
	,N'Dear valued agents,<br />
Please be informed that some of your Agents were disabled due to their Member inactivity in the past 4 months. Their credit has been cleared and your given credit has been decreased by the total cleared amounts. Please note that disabled accounts will not be restored.<br />
Thank you.'

	,N'Kính gửi quý khách hàng,<br />
Xin lưu ý rằng một số Agent của bạn đã bị vô hiệu hoá do Member của họ không hoạt động trong 4 tháng qua. Tín dụng của họ đã bị xoá và tín dụng có thể cấp của bạn đã bị giảm bởi tổng số tín dụng bị xoá này. Lưu ý rằng tài khoản bị vô hiệu hoá sẽ không thể phục hồi.<br />
Trân trọng.'

	,N'尊敬的代理們,<br />
特此通知，您的一些代理賬號已被禁用，由於會員已長達四個月無活躍操作。他們的信用已被清除，而您的信用額度也已減少按照被清除的總金額。請知悉，禁用後的賬號將無法重啟。<br />
謝謝。'

	,N'尊敬的代理们,<br />
特此通知，您的一些代理账号已被禁用，由于会员已长达四个月无活跃操作。他们的信用已被清除，而您的信用额度也已减少按照被清除的总金额。请知悉，禁用后的账号将无法重启。<br />
谢谢。'
	
	,N'เรียน ลูกค้าที่เคารพ<br />
ขอแจ้งให้ทราบว่าเอเจนต์บางส่วนของคุณถูกปิด เนื่องจากสมาชิกไม่มีการใช้งานในช่วง 4 เดือนที่ผ่านมา เครดิตของพวกเขาถูกหักล้างและวงเงินเครดิตของคุณถูกลดลงตามจำนวนเงินทั้งหมดที่เคลียร์ โปรดทราบว่าบัญชีที่ถูกปิดใช้งานไม่สามารถกู้คืนได้<br />
ขอบพระคุณ'
)

-----------------------Stage 3 --------------------------
-- M1, M2
,(3, 'M1'
	,N'Dear valued agents,<br />
Please be informed that some of your disabled Agents have been inactive for the past 7 months, their balances have been transferred to you. Please note that disabled accounts will not be restored.<br />
Thank you.'

	,N'Kính gửi quý khách hàng,<br />
Xin lưu ý rằng vài Agent bị vô hiệu hoá của bạn đã không có hoạt động nào trong 7 tháng qua, tín dụng của họ đã được chuyển cho bạn. Lưu ý rằng tài khoản bị vô hiệu hoá sẽ không thể phục hồi.<br />
Trân trọng.'

	,N'尊敬的代理們,<br />
特此通知，您的一些禁用代理已長達七個月無活躍操作，其余額已轉至您的賬戶。請知悉，禁用的賬戶將無法重啟。<br />
謝謝。'

	,N'尊敬的代理们,<br />
特此通知，您的一些禁用代理已长达七个月无活跃操作，其余额已转至您的账户。请知悉，禁用的账户将无法重启。<br />
谢谢。'

	,N'เรียน ลูกค้าที่เคารพ<br />
ขอแจ้งให้ทราบว่าเอเจนต์บางส่วนของคุณไม่ได้ใช้งานในช่วง 7 เดือนที่ผ่านมาและยอดเงินของพวกเขาได้ถูกโอนมาให้คุณ โปรดทราบว่าบัญชีที่ถูกปิดใช้งานไม่สามารถกู้คืนได้<br />
ขอบพระคุณ'
)
,(3, 'M2'
	,N'Dear valued agents,<br />
Please be informed that some of your disabled Agents have been inactive for the past 7 months, their balances have been transferred to you. Please note that disabled accounts will not be restored.<br />
Thank you.'

	,N'Kính gửi quý khách hàng,<br />
Xin lưu ý rằng vài Agent bị vô hiệu hoá của bạn đã không có hoạt động nào trong 7 tháng qua, tín dụng của họ đã được chuyển cho bạn. Lưu ý rằng tài khoản bị vô hiệu hoá sẽ không thể phục hồi.<br />
Trân trọng.'

	,N'尊敬的代理們,<br />
特此通知，您的一些禁用代理已長達七個月無活躍操作，其余額已轉至您的賬戶。請知悉，禁用的賬戶將無法重啟。<br />
謝謝。'

	,N'尊敬的代理们,<br />
特此通知，您的一些禁用代理已长达七个月无活跃操作，其余额已转至您的账户。请知悉，禁用的账户将无法重启。<br />
谢谢。'

	,N'เรียน ลูกค้าที่เคารพ<br />
ขอแจ้งให้ทราบว่าเอเจนต์บางส่วนของคุณไม่ได้ใช้งานในช่วง 7 เดือนที่ผ่านมาและยอดเงินของพวกเขาได้ถูกโอนมาให้คุณ โปรดทราบว่าบัญชีที่ถูกปิดใช้งานไม่สามารถกู้คืนได้<br />
ขอบพระคุณ'
)