-- CreateEnum
CREATE TYPE "Role" AS ENUM ('ADMIN', 'ORGANIZER', 'JUDGE', 'PARTICIPANT');

-- CreateEnum
CREATE TYPE "HackathonStatus" AS ENUM ('DRAFT', 'PUBLISHED', 'REGISTRATION_OPEN', 'SUBMISSION_OPEN', 'JUDGING', 'COMPLETED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "TeamMemberRole" AS ENUM ('LEADER', 'MEMBER');

-- CreateEnum
CREATE TYPE "ProjectStatus" AS ENUM ('DRAFT', 'SUBMITTED', 'DISQUALIFIED');

-- CreateEnum
CREATE TYPE "InviteStatus" AS ENUM ('PENDING', 'ACCEPTED', 'DECLINED', 'EXPIRED');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "avatarUrl" TEXT,
    "bio" TEXT,
    "skills" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "role" "Role" NOT NULL DEFAULT 'PARTICIPANT',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "hackathons" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "theme" TEXT,
    "bannerUrl" TEXT,
    "status" "HackathonStatus" NOT NULL DEFAULT 'DRAFT',
    "maxTeamSize" INTEGER NOT NULL DEFAULT 4,
    "minTeamSize" INTEGER NOT NULL DEFAULT 1,
    "registrationOpensAt" TIMESTAMP(3) NOT NULL,
    "registrationClosesAt" TIMESTAMP(3) NOT NULL,
    "submissionOpensAt" TIMESTAMP(3) NOT NULL,
    "submissionClosesAt" TIMESTAMP(3) NOT NULL,
    "judgingStartsAt" TIMESTAMP(3) NOT NULL,
    "judgingEndsAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "organizerId" TEXT NOT NULL,

    CONSTRAINT "hackathons_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tracks" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "hackathonId" TEXT NOT NULL,

    CONSTRAINT "tracks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "prizes" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "value" TEXT,
    "rank" INTEGER NOT NULL DEFAULT 1,
    "hackathonId" TEXT NOT NULL,
    "trackId" TEXT,

    CONSTRAINT "prizes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "teams" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "inviteCode" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "hackathonId" TEXT NOT NULL,
    "trackId" TEXT,

    CONSTRAINT "teams_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "team_members" (
    "id" TEXT NOT NULL,
    "role" "TeamMemberRole" NOT NULL DEFAULT 'MEMBER',
    "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "teamId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,

    CONSTRAINT "team_members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "team_invites" (
    "id" TEXT NOT NULL,
    "status" "InviteStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "respondedAt" TIMESTAMP(3),
    "teamId" TEXT NOT NULL,
    "senderId" TEXT NOT NULL,
    "receiverId" TEXT NOT NULL,

    CONSTRAINT "team_invites_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "projects" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "repoUrl" TEXT,
    "demoUrl" TEXT,
    "videoUrl" TEXT,
    "techStack" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "status" "ProjectStatus" NOT NULL DEFAULT 'DRAFT',
    "submittedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "hackathonId" TEXT NOT NULL,
    "trackId" TEXT,
    "teamId" TEXT NOT NULL,

    CONSTRAINT "projects_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "judging_criteria" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "maxScore" INTEGER NOT NULL DEFAULT 10,
    "weight" DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    "hackathonId" TEXT NOT NULL,

    CONSTRAINT "judging_criteria_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "judge_assignments" (
    "id" TEXT NOT NULL,
    "assignedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "hackathonId" TEXT NOT NULL,
    "judgeId" TEXT NOT NULL,
    "projectId" TEXT NOT NULL,

    CONSTRAINT "judge_assignments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "scores" (
    "id" TEXT NOT NULL,
    "value" DOUBLE PRECISION NOT NULL,
    "feedback" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "projectId" TEXT NOT NULL,
    "judgeId" TEXT NOT NULL,
    "criteriaId" TEXT NOT NULL,

    CONSTRAINT "scores_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "announcements" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "hackathonId" TEXT NOT NULL,
    "authorId" TEXT NOT NULL,

    CONSTRAINT "announcements_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "hackathons_slug_key" ON "hackathons"("slug");

-- CreateIndex
CREATE INDEX "hackathons_status_idx" ON "hackathons"("status");

-- CreateIndex
CREATE UNIQUE INDEX "teams_inviteCode_key" ON "teams"("inviteCode");

-- CreateIndex
CREATE UNIQUE INDEX "teams_hackathonId_name_key" ON "teams"("hackathonId", "name");

-- CreateIndex
CREATE UNIQUE INDEX "team_members_teamId_userId_key" ON "team_members"("teamId", "userId");

-- CreateIndex
CREATE UNIQUE INDEX "team_invites_teamId_receiverId_key" ON "team_invites"("teamId", "receiverId");

-- CreateIndex
CREATE UNIQUE INDEX "projects_teamId_key" ON "projects"("teamId");

-- CreateIndex
CREATE UNIQUE INDEX "judge_assignments_judgeId_projectId_key" ON "judge_assignments"("judgeId", "projectId");

-- CreateIndex
CREATE UNIQUE INDEX "scores_projectId_judgeId_criteriaId_key" ON "scores"("projectId", "judgeId", "criteriaId");

-- AddForeignKey
ALTER TABLE "hackathons" ADD CONSTRAINT "hackathons_organizerId_fkey" FOREIGN KEY ("organizerId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tracks" ADD CONSTRAINT "tracks_hackathonId_fkey" FOREIGN KEY ("hackathonId") REFERENCES "hackathons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "prizes" ADD CONSTRAINT "prizes_hackathonId_fkey" FOREIGN KEY ("hackathonId") REFERENCES "hackathons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "prizes" ADD CONSTRAINT "prizes_trackId_fkey" FOREIGN KEY ("trackId") REFERENCES "tracks"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "teams" ADD CONSTRAINT "teams_hackathonId_fkey" FOREIGN KEY ("hackathonId") REFERENCES "hackathons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "teams" ADD CONSTRAINT "teams_trackId_fkey" FOREIGN KEY ("trackId") REFERENCES "tracks"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "team_members" ADD CONSTRAINT "team_members_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "teams"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "team_members" ADD CONSTRAINT "team_members_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "team_invites" ADD CONSTRAINT "team_invites_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "teams"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "team_invites" ADD CONSTRAINT "team_invites_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "team_invites" ADD CONSTRAINT "team_invites_receiverId_fkey" FOREIGN KEY ("receiverId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_hackathonId_fkey" FOREIGN KEY ("hackathonId") REFERENCES "hackathons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_trackId_fkey" FOREIGN KEY ("trackId") REFERENCES "tracks"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "teams"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "judging_criteria" ADD CONSTRAINT "judging_criteria_hackathonId_fkey" FOREIGN KEY ("hackathonId") REFERENCES "hackathons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "judge_assignments" ADD CONSTRAINT "judge_assignments_hackathonId_fkey" FOREIGN KEY ("hackathonId") REFERENCES "hackathons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "judge_assignments" ADD CONSTRAINT "judge_assignments_judgeId_fkey" FOREIGN KEY ("judgeId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "judge_assignments" ADD CONSTRAINT "judge_assignments_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "scores" ADD CONSTRAINT "scores_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "scores" ADD CONSTRAINT "scores_judgeId_fkey" FOREIGN KEY ("judgeId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "scores" ADD CONSTRAINT "scores_criteriaId_fkey" FOREIGN KEY ("criteriaId") REFERENCES "judging_criteria"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "announcements" ADD CONSTRAINT "announcements_hackathonId_fkey" FOREIGN KEY ("hackathonId") REFERENCES "hackathons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "announcements" ADD CONSTRAINT "announcements_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
