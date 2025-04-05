#!/bin/bash

# Create and activate conda environment
conda env create -f environment.yml
conda activate blockchain-voting

# Install project dependencies
npm install

# Initialize Prisma
cd backend
npx prisma generate
npx prisma db push

# Start services
cd ..
npm run dev 