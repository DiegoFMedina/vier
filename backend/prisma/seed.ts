import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  const passwordHash = await bcrypt.hash('vier1234', 10);

  const admin = await prisma.user.upsert({
    where: { email: 'admin@vier.cl' },
    update: {},
    create: {
      email: 'admin@vier.cl',
      passwordHash,
      nombre: 'Administrador',
      role: 'ADMIN',
    },
  });

  console.log('Usuario de prueba:', admin.email, '/ password: vier1234');
}

main()
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
