// START AUTOGEN

import type { Post } from "./Post";
import type { User } from "./User";

type Model = {
  id: number;
  type: "comments";
  text: string;
  createdAt: string;
  updatedAt: string;
  relationships: {
    /** Author of the comment. */
    user: User;
    deletedBy?: User;
    commentable?: Post;
  };
};

// END AUTOGEN

type Comment = Model;

export { type Comment };
