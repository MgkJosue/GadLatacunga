import databases
import sqlalchemy


#DATABASE_URL = "postgresql://tu_usuario:tu_contraseña@tu_host:tu_puerto/tu_base_datos"
DATABASE_URL = "postgresql://postgres:admin@localhost/conceptGadLatacunga"

database = databases.Database(DATABASE_URL)
metadata = sqlalchemy.MetaData()
engine = sqlalchemy.create_engine(DATABASE_URL)
