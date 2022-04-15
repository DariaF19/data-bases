# 1 Добавление внешних ключей
ALTER TABLE dealer
	ADD FOREIGN KEY(id_company) REFERENCES company(id_company);
ALTER TABLE production
	ADD FOREIGN KEY(id_company) REFERENCES company(id_company);
ALTER TABLE `order`
	ADD FOREIGN KEY(id_production) REFERENCES production(id_production);
ALTER TABLE `order`
	ADD FOREIGN KEY(id_pharmacy) REFERENCES pharmacy(id_pharmacy);
ALTER TABLE production
	ADD FOREIGN KEY(id_medicine) REFERENCES medicine(id_medicine);
ALTER TABLE `order`
	ADD FOREIGN KEY(id_dealer) REFERENCES dealer(id_dealer);

# 2 Выдать информацию по всем заказам лекарства “Кордерон” компании “Аргус” с указанием названий аптек, дат, объема заказов
SELECT pharmancy.name, order.date, order.quantity FROM `order`
	LEFT JOIN pharmacy ON pharmancy.id_pharmacy = order.id_pharmacy
	LEFT JOIN production ON production.id_production = order.id_production
	LEFT JOIN company ON company.id_company = production.id_company
	LEFT JOIN medicine ON medicine.id_medicine = production.id_medicine
	WHERE medicine.name = 'Кордерон' AND company.name = 'Аргус';

# 3 Дать список лекарств компании “Фарма”, на которые не были сделаны заказы до 25 января
SELECT medicine.name FROM medicine WHERE medicine.id_medicine NOT IN (
	SELECT medicine.id_medicine FROM medicine
	LEFT JOIN production ON production.id_medicine = medicine.id_medicine
	LEFT JOIN company ON company.id_company = production.id_company
	INNER JOIN `order` ON order.id_production = production.id_production
	WHERE company.name = 'Фарма'
	GROUP BY medicine.id_medicine
	HAVING (MIN(order.date) > '2019-02-25')
	);

# 4 Дать минимальный и максимальный баллы лекарств каждой фирмы, которая оформила не менее 120 заказов
SELECT company.name, MIN(production.rating) AS min_rating, MAX(production.rating) AS max_rating FROM medicine
	LEFT JOIN production ON production.id_medicine = medicine.id_medicine
	LEFT JOIN company ON company.id_company = production.id_company
	LEFT JOIN `order` ON order.id_production = production.id_production
	GROUP BY company.name
	HAVING COUNT(order.id_order) >= 120;

# 5 Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”. Если у дилера нет заказов, в названии аптеки проставить NULL
SELECT pharmacy.name, dealer.name FROM company
	LEFT JOIN dealer ON dealer.id_company = company.id_company
	LEFT JOIN `order` ON order.id_dealer = dealer.id_dealer
	LEFT JOIN pharmacy ON pharmancy.id_pharmacy = order.id_pharmacy
	WHERE company.name = 'AstraZeneca';

# 6 Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а длительность лечения не более 7 дней
UPDATE production
	LEFT JOIN medicine ON medicine.id_medicine = production.id_medicine
	SET price = (price * 0.8)
	WHERE production.price > 3000 AND medicine.cure_duration <= 7;

# 7 Добавление необходимых индексов
CREATE INDEX index_production_price ON production(price);
CREATE INDEX index_medicine_cure_duration ON medicine(cure_duration);
CREATE INDEX index_company_name ON company(name);
CREATE INDEX index_medicine_name ON medicine(name);
CREATE INDEX index_order_date ON `order`(date);