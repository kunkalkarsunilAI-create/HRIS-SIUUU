insert into public.employees (id,name,email,phone,designation,dept,manager_id,doj,location,type,status,lwd,el_carry) values
('EMP001','Anand Joshi','anand.joshi@sahyadritech.in','9807311937','Chief Executive Officer','Leadership',null,'2015-04-01','Pune','Full-time','Active',null,30),
('EMP002','Priya Kulkarni','priya.kulkarni@sahyadritech.in','9814623874','HR Manager','People','EMP001','2018-06-11','Pune','Full-time','Active',null,30),
('EMP003','Farhan Shaikh','farhan.shaikh@sahyadritech.in','9821935811','Finance Lead','Finance','EMP001','2019-01-07','Pune','Full-time','Active',null,27),
('EMP004','Rahul Deshmukh','rahul.deshmukh@sahyadritech.in','9829247748','Engineering Manager','Engineering','EMP001','2017-08-21','Pune','Full-time','Active',null,30),
('EMP005','Kavya Iyer','kavya.iyer@sahyadritech.in','9836559685','Product Manager','Product','EMP001','2021-03-15','Bengaluru','Full-time','Active',null,19),
('EMP006','Sameer Gupta','sameer.gupta@sahyadritech.in','9843871622','Senior Software Engineer','Engineering','EMP004','2020-11-02','Pune','Full-time','Active',null,20),
('EMP007','Ananya Rao','ananya.rao@sahyadritech.in','9851183559','Senior Software Engineer','Engineering','EMP004','2022-02-14','Bengaluru','Full-time','Active',null,15),
('EMP008','Vikram Singh','vikram.singh@sahyadritech.in','9858495496','QA Engineer','Engineering','EMP004','2023-07-03','Pune','Full-time','Active',null,9),
('EMP009','Neha Patil','neha.patil@sahyadritech.in','9865807433','Software Engineer','Engineering','EMP004','2026-06-01','Pune','Full-time','Probation',null,0),
('EMP010','Arjun Menon','arjun.menon@sahyadritech.in','9873119370','Product Designer','Product','EMP005','2024-01-08','Pune','Full-time','Active',null,7),
('EMP011','Sneha Pawar','sneha.pawar@sahyadritech.in','9880431307','HR Executive','People','EMP002','2025-09-15','Pune','Full-time','Active',null,1),
('EMP012','Rohan Kadam','rohan.kadam@sahyadritech.in','9887743244','Accounts Executive','Finance','EMP003','2024-05-20','Pune','Full-time','Active',null,6),
('EMP013','Pooja Bhosale','pooja.bhosale@sahyadritech.in','9895055181','Engineering Intern','Engineering','EMP006','2026-07-01','Pune','Intern','Active',null,0),
('EMP014','Imran Qureshi','imran.qureshi@sahyadritech.in','9902367118','Office Assistant','Admin','EMP003','2022-10-10','Pune','Full-time','Active',null,12),
('EMP015','Meera Nair','meera.nair@sahyadritech.in','9909679055','Senior Software Engineer','Engineering','EMP004','2019-05-06','Pune','Full-time','Notice','2026-11-20',26);

insert into public.employee_sensitive (employee_id,ctc,gender,pan,uan,aadhaar_last4,bank_last4) values
('EMP001',6000000,'M','AKJPJ4821L','100912345601','4417','1613'),
('EMP002',1800000,'F','BQKPK7710H','100912345602','9032','2226'),
('EMP003',2000000,'M','CZXPS2290M','100912345603','1276','2839'),
('EMP004',3200000,'M','DRTPD5531K','100912345604','6650','3452'),
('EMP005',2600000,'F','EVBPI8803Q','100912345605','3381','4065'),
('EMP006',2200000,'M','FGHPG1145R','100912345606','7724','4678'),
('EMP007',2000000,'F','GHJPR6672T','100912345607','5508','5291'),
('EMP008',900000,'M','HJKPS3398U','100912345608','2290','5904'),
('EMP009',1100000,'F','JKLPP9021V','100912345609','8143','6517'),
('EMP010',1300000,'M','KLMPM4410W','100912345610','6017','7130'),
('EMP011',480000,'F','LMNPP2287X','100912345611','3902','7743'),
('EMP012',360000,'M','MNBPK7765Y','100912345612','4471','8356'),
('EMP013',240000,'F','NBVPB1123Z','100912345613','9988','8969'),
('EMP014',216000,'M','PQRPQ5541A','100912345614','1150','9582'),
('EMP015',2300000,'F','QWEPN8876B','100912345615','7362','0195');

insert into public.documents (employee_id,name,kind,doc_date,status) values
('EMP001','Offer letter','Letter','2015-04-01','Issued'),
('EMP001','PAN card','ID proof','2015-04-01','Verified'),
('EMP001','Aadhaar (masked copy)','ID proof','2015-04-01','Verified'),
('EMP001','Education certificates','Qualification','2015-04-01','Verified'),
('EMP002','Offer letter','Letter','2018-06-11','Issued'),
('EMP002','PAN card','ID proof','2018-06-11','Verified'),
('EMP002','Aadhaar (masked copy)','ID proof','2018-06-11','Verified'),
('EMP002','Education certificates','Qualification','2018-06-11','Verified'),
('EMP003','Offer letter','Letter','2019-01-07','Issued'),
('EMP003','PAN card','ID proof','2019-01-07','Verified'),
('EMP003','Aadhaar (masked copy)','ID proof','2019-01-07','Verified'),
('EMP003','Education certificates','Qualification','2019-01-07','Verified'),
('EMP004','Offer letter','Letter','2017-08-21','Issued'),
('EMP004','PAN card','ID proof','2017-08-21','Verified'),
('EMP004','Aadhaar (masked copy)','ID proof','2017-08-21','Verified'),
('EMP004','Education certificates','Qualification','2017-08-21','Verified'),
('EMP005','Offer letter','Letter','2021-03-15','Issued'),
('EMP005','PAN card','ID proof','2021-03-15','Verified'),
('EMP005','Aadhaar (masked copy)','ID proof','2021-03-15','Verified'),
('EMP005','Education certificates','Qualification','2021-03-15','Verified'),
('EMP006','Offer letter','Letter','2020-11-02','Issued'),
('EMP006','PAN card','ID proof','2020-11-02','Verified'),
('EMP006','Aadhaar (masked copy)','ID proof','2020-11-02','Verified'),
('EMP006','Education certificates','Qualification','2020-11-02','Verified'),
('EMP007','Offer letter','Letter','2022-02-14','Issued'),
('EMP007','PAN card','ID proof','2022-02-14','Verified'),
('EMP007','Aadhaar (masked copy)','ID proof','2022-02-14','Verified'),
('EMP007','Education certificates','Qualification','2022-02-14','Verified'),
('EMP008','Offer letter','Letter','2023-07-03','Issued'),
('EMP008','PAN card','ID proof','2023-07-03','Verified'),
('EMP008','Aadhaar (masked copy)','ID proof','2023-07-03','Verified'),
('EMP008','Education certificates','Qualification','2023-07-03','Verified'),
('EMP009','Offer letter','Letter','2026-06-01','Issued'),
('EMP009','PAN card','ID proof','2026-06-01','Verified'),
('EMP009','Aadhaar (masked copy)','ID proof','2026-06-01','Verified'),
('EMP009','Education certificates','Qualification','2026-06-01','Pending'),
('EMP010','Offer letter','Letter','2024-01-08','Issued'),
('EMP010','PAN card','ID proof','2024-01-08','Verified'),
('EMP010','Aadhaar (masked copy)','ID proof','2024-01-08','Verified'),
('EMP010','Education certificates','Qualification','2024-01-08','Verified'),
('EMP011','Offer letter','Letter','2025-09-15','Issued'),
('EMP011','PAN card','ID proof','2025-09-15','Verified'),
('EMP011','Aadhaar (masked copy)','ID proof','2025-09-15','Verified'),
('EMP011','Education certificates','Qualification','2025-09-15','Verified'),
('EMP012','Offer letter','Letter','2024-05-20','Issued'),
('EMP012','PAN card','ID proof','2024-05-20','Verified'),
('EMP012','Aadhaar (masked copy)','ID proof','2024-05-20','Verified'),
('EMP012','Education certificates','Qualification','2024-05-20','Verified'),
('EMP013','Offer letter','Letter','2026-07-01','Issued'),
('EMP013','PAN card','ID proof','2026-07-01','Verified'),
('EMP013','Aadhaar (masked copy)','ID proof','2026-07-01','Verified'),
('EMP013','Education certificates','Qualification','2026-07-01','Pending'),
('EMP014','Offer letter','Letter','2022-10-10','Issued'),
('EMP014','PAN card','ID proof','2022-10-10','Verified'),
('EMP014','Aadhaar (masked copy)','ID proof','2022-10-10','Verified'),
('EMP014','Education certificates','Qualification','2022-10-10','Verified'),
('EMP015','Offer letter','Letter','2019-05-06','Issued'),
('EMP015','PAN card','ID proof','2019-05-06','Verified'),
('EMP015','Aadhaar (masked copy)','ID proof','2019-05-06','Verified'),
('EMP015','Education certificates','Qualification','2019-05-06','Verified'),
('EMP015','Resignation email','Exit','2026-10-21','Received');

insert into public.leave_requests (id,employee_id,type,from_date,to_date,status,reason,applied_on,history) values
('LV101','EMP007','ML','2026-09-14','2027-03-14','Approved','Maternity leave','2026-08-20','[{"at":"2026-08-20 10:00","by":"EMP007","act":"Applied"},{"at":"2026-08-20 15:30","by":"EMP004","act":"Approved"}]'::jsonb),
('LV102','EMP006','SL','2026-10-12','2026-10-13','Approved','Fever','2026-10-12','[{"at":"2026-10-12 10:00","by":"EMP006","act":"Applied"},{"at":"2026-10-12 15:30","by":"EMP004","act":"Approved"}]'::jsonb),
('LV103','EMP014','LOP','2026-10-22','2026-10-23','Approved','Personal work, no balance','2026-10-19','[{"at":"2026-10-19 10:00","by":"EMP014","act":"Applied"},{"at":"2026-10-19 15:30","by":"EMP003","act":"Approved"}]'::jsonb),
('LV104','EMP009','EL','2026-11-11','2026-11-13','Pending manager','Diwali at home in Kolhapur','2026-10-28','[{"at":"2026-10-28 10:00","by":"EMP009","act":"Applied"}]'::jsonb),
('LV105','EMP008','CL','2026-11-02','2026-11-02','Pending manager','Bank work','2026-10-29','[{"at":"2026-10-29 10:00","by":"EMP008","act":"Applied"}]'::jsonb),
('LV106','EMP010','EL','2026-11-16','2026-11-27','Pending HR','Family wedding in Kochi','2026-10-26','[{"at":"2026-10-26 10:00","by":"EMP010","act":"Applied"},{"at":"2026-10-26 16:10","by":"EMP005","act":"Approved by manager, sent to HR (more than 5 days)"}]'::jsonb),
('LV107','EMP003','EL','2026-08-03','2026-08-07','Approved','Vacation','2026-07-15','[{"at":"2026-07-15 10:00","by":"EMP003","act":"Applied"},{"at":"2026-07-15 15:30","by":"EMP001","act":"Approved"}]'::jsonb),
('LV108','EMP009','SL','2026-09-08','2026-09-08','Approved','Migraine','2026-09-08','[{"at":"2026-09-08 10:00","by":"EMP009","act":"Applied"},{"at":"2026-09-08 15:30","by":"EMP004","act":"Approved"}]'::jsonb),
('LV109','EMP012','CL','2026-10-29','2026-10-30','Approved','Sister''s engagement','2026-10-20','[{"at":"2026-10-20 10:00","by":"EMP012","act":"Applied"},{"at":"2026-10-20 15:30","by":"EMP003","act":"Approved"}]'::jsonb),
('LV110','EMP013','CL','2026-10-05','2026-10-05','Rejected','Trip','2026-10-03','[{"at":"2026-10-03 10:00","by":"EMP013","act":"Applied"},{"at":"2026-10-03 12:00","by":"EMP006","act":"Rejected: release sprint"}]'::jsonb);

insert into public.audit_log (at,by_employee,action) values
('2026-10-28 10:02:00+05:30','EMP009','Applied for leave LV104 (EL, 3 days)'),
('2026-10-26 16:10:00+05:30','EMP005','Approved LV106 at manager level; sent to HR'),
('2026-10-21 18:45:00+05:30','EMP002','Recorded resignation of EMP015 Meera Nair; LWD 20 Nov 2026'),
('2026-10-19 11:20:00+05:30','EMP003','Approved LOP for EMP014 (2 days)');

-- Demo logins (password: Sahyadri@2026). Change these before any real use.
do $$
declare r record; uid uuid;
begin
  for r in select * from (values ('priya.kulkarni@sahyadritech.in','EMP002','hr_admin'),('rahul.deshmukh@sahyadritech.in','EMP004','manager'),('neha.patil@sahyadritech.in','EMP009','employee')) as v(email,emp,role) loop
    uid := gen_random_uuid();
    insert into auth.users (instance_id,id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at,confirmation_token,email_change,email_change_token_new,recovery_token)
    values ('00000000-0000-0000-0000-000000000000',uid,'authenticated','authenticated',r.email,extensions.crypt('Sahyadri@2026',extensions.gen_salt('bf')),now(),'{"provider":"email","providers":["email"]}','{}',now(),now(),'','','','');
    insert into auth.identities (id,user_id,provider_id,identity_data,provider,last_sign_in_at,created_at,updated_at)
    values (gen_random_uuid(),uid,uid::text,jsonb_build_object('sub',uid::text,'email',r.email,'email_verified',true),'email',now(),now(),now());
    insert into public.user_roles (user_id,employee_id,role) values (uid,r.emp,r.role);
  end loop;
end $$;

-- Which email signs in as which employee (used by Clerk sign-in)
insert into public.app_logins (email, employee_id, role) values
('priya.kulkarni@sahyadritech.in','EMP002','hr_admin'),
('rahul.deshmukh@sahyadritech.in','EMP004','manager'),
('neha.patil@sahyadritech.in','EMP009','employee');
